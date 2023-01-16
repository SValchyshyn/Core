//
//  BasicAlertViewController.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 02.03.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit
import Core
import CoreNavigation
import Log
import Tracking

open class BasicAlertViewController: UIViewController, Trackable {

	public enum Notifications {

		/// Send close alerts notification to close open BasicAlertViewController's without animation and without calling any completion blocks
		public static let closeAlerts: NSNotification.Name = .init( "closeAlerts" )
	}

	private enum Constants {
		/// The background color of the `UIView` in which the `alert` is embedded.
		static let backgroundViewAlpha: CGFloat = 0.75

		/// All the direct subviews of the `.view` property are constrained relative to the layoutMargin. By modifying it we make sure that the changes
		/// will be uniform across all of them.
		static let layoutMargins: UIEdgeInsets = .init( top: 26.0, left: 20.0, bottom: 20.0, right: 20.0 )

		/// The maximum height that the `messageLabel` is allowed to have.
		static let maxMessageHeight: CGFloat = 200.0

		/// The height of the underlined button
		static let underlinedButtonHeight: CGFloat = 20
	}

	// MARK: - Tracking.

	public lazy var trackingPageId: String = trackingConfiguration?.pageId ?? ""
	public lazy var trackingPageName: String = trackingConfiguration?.pageName ?? ""

	// MARK: - Outlets

	@IBOutlet private(set) weak var titleLabel: UILabel! {
		didSet {
			titleLabel.textColor = colorsContent.bodyTextColor
			titleLabel.font = fontProvider.H5HeaderFont
		}
	}
	// Instead of using a UITextView (which is usually used for editing as well) embed the `messageLabel` into a `UIScrollView
	// so we can also get the CLickableLinkLabel functionality for free.
	// The messageLabelScrollView will have 2 important constraints:
	// 1 - equal height with the whole view. Priority: 248 ~ this will allow the frame of the UIScrollView to expand as much as possible
	// 2 - lessThanOrEqual constraint on the height (`messageScrollViewHeightLessThanConstraint`). Priority: 249 with which we will modify based on the contentSize.
	//		This is only important for the cases in which the UIScrollView doesn't need to scroll as the content fits in the screen.
	// For situations in which the contentSize is way bigger than the space available on the screen, the first constraint in combination with the second
	// will make sure that the UIScrollView will expand as much as possible.
	// The priorities are the ones specified because there is also a constraint between the view.bottom that contains the title and message labels
	// and the top of the buttons view, which has priority 250. This will make sure that if the bottomCustomizationContainerView has no content, we still
	// respect a distance between the labels and the buttons even if the UIScrollView is allowed to expand as much as possible.
	@IBOutlet private(set) weak var messageLabelScrollView: UIScrollView!
	@IBOutlet private(set) weak var messageScrollViewHeightLessThanConstraint: NSLayoutConstraint!
	@IBOutlet private(set) weak var messageLabel: ClickableLinkLabel! {
		didSet {
			messageLabel.textColor = colorsContent.bodyTextColor
			messageLabel.font = fontProvider[.regular( .body )]
		}
	}

	@IBOutlet weak var buttonsStackView: UIStackView!
	@IBOutlet public private(set) weak var topButton: UIButton!{
		didSet {
			// Setup colors
			topButton.backgroundColor = colorsContent.primaryColor
			topButton.titleLabel?.font = fontProvider[.medium( .body )]
		}
	}

	private lazy var bottomButton: UIButton = {
		// Create the correct type of button
		let button: UIButton = configuration.bottomButton?.buttonStyle == .underlined ? UnderlinedButton() : RoundCornerButton()

		// Configure the button
		button.setTitleColor( colorsContent.primaryColor, for: .normal )
		button.titleLabel?.font = fontProvider[.medium( .body )]
		button.addTarget( self, action: #selector(bottomButtonAction(_:)), for: .touchUpInside )

		return button
	}()

	/// Placed between the top of the alert and the top title and message labels.
	@IBOutlet private(set) weak var topCustomizationContainerView: UIView!

	/// Placed between the bottom of the message labels and the top of the buttons.
	@IBOutlet private(set) weak var bottomCustomizationContainerView: UIView!

	@IBOutlet public private(set) weak var contentView: UIView!
	@IBOutlet private weak var centerYConstraint: NSLayoutConstraint!
	@IBOutlet private weak var leadingContentViewConstraint: NSLayoutConstraint!

	/// Constraints which expand the content of the alert. Should be disabled when the conent should be centered, for example in the full screen mode.
	@IBOutlet private var infoBoxExpandingConstraints: [NSLayoutConstraint]!

	/// Constraints which will toggle the alert into a full screen mode
	@IBOutlet private var fullScreenConstraints: [NSLayoutConstraint]!

	// MARK: - Stores properties.

	/// Contains information about the `title` and the `body` of the alert.
	let info: AlertRepresentableInfo

	/// Contains the button actions and other customizations needed for the alert to layout itself.
	let configuration: Configuration

	/// Determines whether we should be remote logging alert actions/ events.
	@FeatureStatusProperty( key: UIFeatures.remoteLoggingAlerts, defaultStatus: .disabled )
	var remoteLoggingAlerts: FeatureStatus

	/// Contains extra information used in `Tracking`.
	// TODO: To be made private and `let` once we transition fully to the new init API. -FAIO
	public var trackingConfiguration: TrackingConfiguration?

	// MARK: - Computed properties.

	/// The technique to use for aligning the title text.
	public var titleTextAlignment: NSTextAlignment? {
		// Keep the optional unwrapping since we might be accessing them before they are bound.
		didSet { titleTextAlignment.map { titleLabel?.textAlignment = $0 } }
	}

	/// The technique to use for aligning the message text in a `UILabel`.
	public var messageTextAlignment: NSTextAlignment? {
		// Keep the optional unwrapping since we might be accessing them before they are bound.
		didSet { messageTextAlignment.map { messageLabel?.textAlignment = $0 } }
	}

	/// Access to modify attributed message outside the initializer.
	public var attributedMessage: NSAttributedString? {
		// Keep the optional unwrapping since we might be accessing them before they are bound.
		didSet { attributedMessage.map { messageLabel?.attributedText = $0 } }
	}

	public override var prefersStatusBarHidden: Bool {
		guard configuration.presentationStyle != .fullScreen else {
			// Hide the status bar for full screen alerts
			return true
		}

		// If the presenting view controller prefers status bar hidden, we'll do the same.
		// If we don't have a presenting view controller (how?), we'll defer to the default implementation
		return previousViewController()?.prefersStatusBarHidden ?? super.prefersStatusBarHidden
	}

	public override var description: String {
		return "BasicAlertViewController. Title: \(titleLabel?.text ?? ""). Message: \( messageLabel?.text ?? "")"
	}

	// We want to participate in the main alert queue
	override var presentationAlertCoordinator: AlertCoordinator? { .shared }

	/// Used to keep track of the height observation of the `messageLabelScrollView`.
	private var _token: NSKeyValueObservation?

	// MARK: - Init.

	/// Initialize custom alert dialog.
	/// **Important:** Must be called on main thread.
	///
	/// - Parameters:
	///   - title: Title for the alert
	///   - message: Text message for the alert
	///   - topAction: Custom alert action for the top button. If not specified the button is removed.
	///   - bottomAction: Custom alert action for the bottom button. If not specified the button is removed.
	///   - seeMoreMessage: See more message. Only shown in Debug configuration.
	///   - presentationStyle: Defines how the alert should be positioned on the screen.
	///   - accessibilityIdentifier: Identifier used for finding the alert during UI tests.
	///   - trackingConfiguration: Configuration used when tracking the appearance of the alert. If it is set to `nil` nothing is tracked.
	///	  - attributedMessage: Text message for the alert usign custom text attributes
	public convenience init( title: String,
							 message: String,
							 topAction: CustomAlertAction,
							 bottomAction: CustomAlertAction? = nil,
							 seeMoreMessage: String? = nil,
							 presentationStyle: Configuration.PresentationStyle = .fullWidth,
							 accessibilityIdentifier: String? = nil,
							 trackingConfiguration: TrackingConfiguration? = nil,
							 attributedTitle: NSAttributedString? = nil,
							 attributedMessage: NSAttributedString? = nil ) {
		// Map the title and body to an AlertRepresentableError.
		let error: AlertRepresentableInfo
		if attributedMessage != nil || attributedTitle != nil {
			error = CoreBaseRichInfo( title: title, attributedTitle: attributedTitle, attributedBody: attributedMessage )
		} else {
			error = CoreBaseError( title: title, body: message )
		}

		// Create the base configuration
		var configuration = BasicAlertViewController.Configuration(
			presentationStyle: presentationStyle,
			seeMoreMessage: seeMoreMessage,
			accessibilityIdentifier: accessibilityIdentifier
		)

		// Add top button.
		configuration = configuration.byAdding(
			topButton: .init( title: .custom( title: topAction.title ), dismissAlert: topAction.dismissAlert, action: topAction.handler )
		)
		
		if let bottomAction = bottomAction {
			// Map the bottom button.
			configuration = configuration.byAdding(
				bottomButton: .init( title: .custom( title: bottomAction.title ), dismissAlert: bottomAction.dismissAlert, action: bottomAction.handler )
			)
		}

		// Use the convenience init.
		self.init( info: error, configuration: configuration )
		self.trackingConfiguration = trackingConfiguration
	}

	/// - Parameters:
	///   - info: Used to configure the content of the `alert`.
	///   - configuration: Used to configure the UI based on the provided actions and information.
	public init( info: AlertRepresentableInfo, configuration: Configuration ) {
		// Remember the tracking configuration
		self.info = info
		self.configuration = configuration
		super.init( nibName: String( describing: BasicAlertViewController.self ), bundle: Bundle( for: BasicAlertViewController.self ) )

		// Setup modal behaviour
		switch configuration.presentationStyle {
		case .fullWidth:
			modalPresentationStyle = .overFullScreen

		case .fullScreen:
			modalPresentationStyle = .fullScreen
		}

		modalTransitionStyle = .crossDissolve
	}

	public required init?( coder: NSCoder ) {
		fatalError( "init(coder:) has not been implemented" )
	}

	// MARK: - View methods.

	open override func loadView() {
		super.loadView()

		// Color adjustments.
		view.tintColor = Theme.Colors.darkGray
		view.backgroundColor = UIColor.black.withAlphaComponent( Constants.backgroundViewAlpha )

		contentView.layoutMargins = Constants.layoutMargins

		// Set an accessibilityIdentifier if it is provided.
		configuration.accessibilityIdentifier.map { view.accessibilityIdentifier = $0 }

		// Perform any customizations requested, if any.
		titleTextAlignment.map { titleLabel?.textAlignment = $0 }
		messageTextAlignment.map { messageLabel?.textAlignment = $0 }
		attributedMessage.map { messageLabel?.attributedText = $0 }

		if configuration.presentationStyle == .fullScreen {
			// Change the background color
			contentView.backgroundColor = colorsContent.colorBackground

			// Adjust the constraints so the content view extends on the whole screen
			fullScreenConstraints.forEach{ $0.isActive = true }

			// Disable the constraints for the information box, so the view can get centered.
			// We have relevant constraints in Interface Builder which will take over once these are deactivated
			infoBoxExpandingConstraints.forEach{ $0.isActive = false }
		}

		// Add the bottom button to the stack view
		buttonsStackView.addArrangedSubview( bottomButton )

		// Set the correct height constraint
		if bottomButton is UnderlinedButton {
			bottomButton.heightAnchor.constraint( equalToConstant: Constants.underlinedButtonHeight ).isActive = true
		} else {
			bottomButton.heightAnchor.constraint( equalTo: topButton.heightAnchor ).isActive = true
			bottomButton.widthAnchor.constraint( equalTo: topButton.widthAnchor ).isActive = true
		}
	}

	open override func viewDidLoad() {
		super.viewDidLoad()

		// Add some insets to mimic the old appearance that the old UITextView implementation had.
		messageLabelScrollView.contentInset = .zero
		// Make sure to match the size of the scrollView so we can adjust it to scroll/ not to scroll depending on the context.
		_token = messageLabelScrollView.observe( \.contentSize, options: .new, changeHandler: { [weak self] _, change in
			guard let newValue = change.newValue, let `self` = self else { return }

			// Modify the lessThanOrEqualTo constraint to be the total contentSize.
			// This is important for the scrollViews which have a contentSize less than the remaining space on the screen.
			// If we want the scrollView to fill up all the space that there is on the screen, we can simply set the constraint from the first time to UIScreen.main.bounds.height.
			// But if the contentSize is smaller than all the space on the screen, the scrollView will still occupy all the space, which is not what we want.
			// Since the constraint is control the scroll view's height, make sure to take into consideration the vertical insets as well.
			self.messageScrollViewHeightLessThanConstraint?.constant = newValue.height + self.messageLabelScrollView.contentInset.top + self.messageLabelScrollView.contentInset.bottom
		} )

		// Apply the changes to the UI based on how the alert has been created.
		setupUI()

		// React to the `closeAlerts` notification so we can automatically dismiss ourselves.
		NotificationCenter.default.addObserver( self, selector: #selector( closeAlertsNotificationReceived(_:)), name: Notifications.closeAlerts, object: nil )
	}

	open override func viewDidAppear( _ animated: Bool ) {
		super.viewDidAppear( animated )

		if remoteLoggingAlerts.isEnabled {
			let payload = """
			Title: \(titleLabel.text ?? "")
			Top Action: \(configuration.topButton?.title ?? "nil")
			Bottom Action: \(configuration.bottomButton?.title ?? "nil")
			"""
			Log.technical.log(.info, payload, [.identifier("BasicAlertViewController.viewDidAppear")])
		}

		// Track the alert only if tracking configuration is set
		if let trackingConfiguration = trackingConfiguration {
			// Append the event type "alert"
			var parameters = trackingConfiguration.parameters
			parameters.append(.alert.alertEventType)
			trackViewController( parameters: parameters )
		}

		// Try to flash the indicators. This will have no effect is the frame of the UIScrollView matches its contentSize, so it's safe.
		messageLabelScrollView.flashScrollIndicators()
	}

	public override func viewWillDisappear( _ animated: Bool ) {
		super.viewWillDisappear( animated )

		// Invalidate the observation when dismissing the screen.
		_token?.invalidate()
	}

	// MARK: - IBAction methods

	@IBAction func topButtonAction( _ sender: AnyObject? ) {
		guard let button = configuration.topButton else { return }

		if remoteLoggingAlerts.isEnabled {
			Log.technical.log(.info, "Performing top action", [.identifier("BasicAlertViewController.performAction")])
		}
		performAction( for: button )
	}

	@objc func bottomButtonAction( _ sender: AnyObject? ) {
		guard let button = configuration.bottomButton else { return }

		if remoteLoggingAlerts.isEnabled {
			Log.technical.log(.info, "Performing bottom action", [.identifier("BasicAlertViewController.performAction")])
		}
		performAction( for: button )
	}

	// MARK: - Selectors.

	@objc private func closeAlertsNotificationReceived( _ notification: Notification ) {
		if remoteLoggingAlerts.isEnabled {
			Log.technical.log(.info, "Closing alert due to notification", [.identifier("BasicAlertViewController.closeAlert")])
		}
		dismiss( animated: false )
	}

	// MARK: - Utils.

	/// We want to compare the alerts by their content, instead of the default comparison.
	open override func isEqual( _ object: Any? ) -> Bool {
		guard let alert = object as? BasicAlertViewController else { return false }

		// Compare the textual content to determine whether the alerts are equal or not.
		return titleLabel?.text == alert.titleLabel?.text && messageLabel?.text == alert.messageLabel?.text
	}

	/// Raises the UI so the keyboard does not interfere with the content.
	/// For positive values, the content will be moved upwards, for negative values, downwards. `0` will place the content in the center of the screen.
	/// - Parameter adjustmentOffset: Value, in `points`, relative to the center of the `view` by which the content should be modified.
	open func prepareUIForKeyboard( adjustmentOffset: CGFloat ) {
		centerYConstraint.constant = adjustmentOffset

		// Animate the constraint change.
		UIView.animate( withDuration: Theme.Durations.standardAnimationDuration ) {
			self.view.layoutIfNeeded()
		}
	}

	/// Returns the height `NSLayoutConstraint`of the component that represents the main method of displaying the message/ description/ body of the alert.
	/// The constraint is not considered to be activated, hence, the caller should make sure of that.
	open func determineMessageHeightConstraint() -> NSLayoutConstraint? {
		messageLabel.heightAnchor.constraint( lessThanOrEqualToConstant: Constants.maxMessageHeight )
	}

	/// Configures the title `UILabel` of the alert.
	open func configureTitleMessage() {
		// Configure title and message labels
		if let richInfo = info as? AlertRepresentableRichInfo, let attributedTitle = richInfo.attributedTitle {
			titleLabel.attributedText = attributedTitle
		} else {
			titleLabel.text = info.title
		}
	}

	/// Configures the longer text/ body/ message/ description `UILabel` that will be displayed in the alert.
	open func configureAlertMessage() {
		messageLabel?.linkTextAttributes = [ .font: messageLabel?.font as Any, .underlineStyle: NSUnderlineStyle.single.rawValue as AnyObject, .foregroundColor: colorsContent.primaryColor ]
		messageLabel?.linkDelegate = self

		if let richInfo = info as? AlertRepresentableRichInfo, let attributedBody = richInfo.attributedBody {
			messageLabel?.attributedText = attributedBody
		} else {
			messageLabel?.text = info.body
		}

#if DEBUG
		// Add "See more" if specified. Only in debug mode
		if !configuration.seeMoreMessage.isNilOrEmpty {
			let seeMoreLink = "<a href=\"err://seemore\">" + CoreLocalizedString( "gen_see_more_prompt" ) + "</a>"
			messageLabel?.text = info.body + "\n\(seeMoreLink)"
		}
#endif
	}

	/// Sets the title, message and other layout modifications needed.
	open func setupUI() {
		// Configure the textual information.
		configureTitleMessage()
		configureAlertMessage()

		// Is top button action specified?
		if configuration.topButton == nil {
			// No: Hide button since it's in a stackView.
			topButton.isHidden = true
		} else {
			// Yes: Configure button
			topButton.setTitleWithoutAnimation( configuration.topButton?.title, for: .normal )
		}

		// Is bottom button action specified?
		if configuration.bottomButton == nil {
			// No: Hide the bottom button
			bottomButton.isHidden = true
		} else {
			// Yes: Set the button title
			bottomButton.setTitleWithoutAnimation( configuration.bottomButton?.title, for: .normal )
			if bottomButton is RoundCornerButton {
				// MARK: Inserted this check and force cast with customInit call because
				// swiftlint:disable force_cast_gp
				(bottomButton as! RoundCornerButton).customInit()
			}
		}
	}

	// MARK: - Private interface.

	/// Performs the action of the `Button` and also `dismisses` the alert if requested.
	/// - Parameter button: Contains information about the action.
	private func performAction( for button: Button ) {
		// First dismiss the alert, and then perform the action.
		if button.dismissAlert {
			dismiss( animated: true ) {
				button.action?( self )
			}
		} else {
			button.action?( self )
		}
	}
}

// MARK: - Clickable link label delegate

extension BasicAlertViewController: ClickableLinkLabelDelegate {

	/// Defines the schemes that we can react to, if provided by the `ClickableLinkLabelDelegate`
	private enum Scheme: String {
		/// Will only be present in `Debug`.
		case err

		/// Used to redirect the user to the help page.
		case faq
	}

	public func clickedLinkWithURL( _ url: URL ) {
		// Do we recognize this scheme?
		guard let urlScheme = url.scheme, let scheme = Scheme( rawValue: urlScheme ) else { return }

		switch scheme {
		case .err:
#if DEBUG
			// If link is err:// then we'll show the see more text. Only in debug mode
			messageLabel?.text = configuration.seeMoreMessage
			UIView.animate( withDuration: Theme.Durations.standardAnimationDuration ) { self.view.layoutIfNeeded() }
#endif

		case .faq:
			// Create the pagein which we'll display the information.
			guard let helpHtmlViewController = UIStoryboard( name: "Help", bundle: Bundle( for: HelpHTMLViewController.self ) )
					.instantiateViewController( withIdentifier: "HelpHTMLViewController" ) as? HelpHtmlAlertViewController else { return }

			// Replace the scheme with an actual URL so we can display it.
			let schemeRange = url.absoluteString.range( of: urlScheme )

			// Provide the actual link.
			helpHtmlViewController.contentURL = URL( string: url.absoluteString.replacingOccurrences( of: urlScheme, with: "https", options: .literal, range: schemeRange ) )

			// And preset the page.
			present( helpHtmlViewController, animated: true, completion: nil )
		}
	}
}

public extension BasicAlertViewController {

	/// Configuration used when tracking the appearance of the alert.
	/// We automatically set the `coop.eventType` to `alert` in the parameters when the alert is tracked.
	struct TrackingConfiguration {

		public let pageId: String
		public var pageName: String?
		public let parameters: [Tracking.Parameter]

		public init( pageId: String, pageName: String? = nil, parameters: [Tracking.Parameter] ) {
			self.pageId = pageId
			self.pageName = pageName
			self.parameters = parameters
		}
	}
}

// MARK: - Protocols for injection

public protocol HelpHtmlAlertViewController where Self: UIViewController {
	var contentURL: URL? { get set }
}
