//
//  BottomSheetContainerViewController.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 10/11/2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import UIKit
import Tracking

public protocol BottomSheetDisplayDelegate: BottomSheetContextDelegate {

	/// Used to control the sheet appearance.
	var sheetDelegate: BottomSheetDelegate? { get set }

	/// The distance, from the top of the content at which the bottom sheet should stop expanding.
	var minBottomSheetDistanceToTop: CGFloat { get }

	/// Informs the `delegate` of the minimum height that the bottom sheet will occupy from the screen.
	/// - Parameter minHeight: Height of the bottom sheet in the `collapsed` state.
	func bottomSheetWillHave( minHeight: CGFloat )
}

public protocol BottomSheetContextDelegate: UIViewController { // swiftlint:disable:this class_delegate_protocol - FAIO

	/// Bottom sheet is ready to display content. Should be used to make the bottom sheet visible.
	func bottomSheetIsReadyToExpand()
}

open class BottomSheetContainerViewController: UIViewController, BottomSheetDelegate, Trackable {
	
	// MARK: - Trackable

	public var trackingPageId = ""
	public var trackingPageName = ""

	// MARK: - Constants

	private enum Constants {
		/// Minumum height for bottom sheet.
		static let minHeight: CGFloat = 52

		/// Offset from topBar when sheet is expanded with max height.
		static let offsetFromTop: CGFloat = 20

		/// Shadow offset
		static let shadowOffset: CGSize = CGSize( width: 0, height: -1 )

		/// Shadow color.
		static let shadowColor: UIColor = .black

		/// Shadow opacity.
		static let shadowOpacity: Float = 0.2

		/// Shadow blur radius.
		static let shadowBlur: CGFloat = 4

		/// Shadow sread.
		static let shadowSpread: CGFloat = 0
	}

	// MARK: - Outlets

	@IBOutlet weak private var sheetContainerView: UIView!
	@IBOutlet weak private var containerView: UIView!
	@IBOutlet weak private var tapBlockingView: UIView!
	@IBOutlet private var topSheetConstraintToSuperviewTop: NSLayoutConstraint!
	@IBOutlet private var sheetHeightConstraint: NSLayoutConstraint!
	@IBOutlet private var tapBlockingViewTopConstraint: NSLayoutConstraint!

	public var sheetView: UIView? {
		sheetContainerView
	}

	/// The contained content `view controller` which is embedded in the `containerView`.
	public var containedViewController: UIViewController {
		_embeddedViewController
	}
		
	// MARK: - Init

	public init( embeddedViewController: BottomSheetDisplayDelegate, sheetContent: DynamicSheetContent ) {
		self._embeddedViewController = embeddedViewController
		self._sheetContent = sheetContent

		super.init( nibName: String( describing: BottomSheetContainerViewController.self ), bundle: Bundle( for: BottomSheetContainerViewController.self ) )

		// Create the connections between the content and the bottom sheet.
		sheetContent.contextDelegate = embeddedViewController
		embeddedViewController.sheetDelegate = self
	}

	public required init?( coder: NSCoder ) {
		fatalError( "init(coder:) has not been implemented" )
	}

	// MARK: - Private.

	open override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	/// Handles the interaction with the bottom sheet in terms of `presentation` or `hiding`.
	private var _bottomSheetManager: DynamicBottomSheetPresentationManager?

	/// Is embedded in the `containerView`.
	private let _embeddedViewController: BottomSheetDisplayDelegate

	/// Is embedded in the `sheetContainerView`.
	private let _sheetContent: DynamicSheetContent

	/// Used to forward information about the presentation of the bottom sheet.
	weak var presentationDelegate: BottomSheetPresentationDelegate?

	/// The state from which the sheet should begin. If `nil` will be hidden until manually displayed.
	var initialState: SheetState?

	// MARK: - Lifecycle

	open override func loadView() {
		super.loadView()

		// Setup the container views with their corresponding content.
		addChild( _sheetContent, to: sheetContainerView )
		addChild( _embeddedViewController, to: containerView )
	}

	open override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear( animated )

		// We need to setup _bottomSheet in viewDidAppear.
		// Since only in this method we know final layout.
		setupBottomSheetHandler()
	}

	// MARK: - Helpers

	/// Adds accessibility information and a shadow on the bottom sheet container.
	open func setupUI() {		
		sheetContainerView.applyShadow(
			color: Constants.shadowColor,
			alpha: Constants.shadowOpacity,
			x: Constants.shadowOffset.width,
			y: Constants.shadowOffset.height,
			blur: Constants.shadowBlur,
			spread: Constants.shadowSpread
		)
	}

	// MARK: - Private interface.

	/// Creates the object that handles the snapping behaviour of the bottom sheet and configures the constraints.
	/// Can be called multiple times, as long as `_bottomSheetHandler != nil` nothing will happen.
	private func setupBottomSheetHandler() {
		// Make sure the handler is not configured already.
		guard _bottomSheetManager == nil else { return }

		// Force view controller view to layout subviews. In this way we can get correct sizes.
		view.layoutIfNeeded()

		// The bottom sheet is constrained to the top of this superview.
		// The _embeddedViewController is found inside the containerView, which is pinned to the superview.Top.
		// Hence, requesting the minBottomSheetDistanceToTop, we'll know the minimum distance that the bottom sheet constraint
		// should have relative to the tap, meaning that this is the value of the topSheetConstraintToSuperviewTop when the sheet is expanded
		let minimumValueOfTopConstraint = _embeddedViewController.minBottomSheetDistanceToTop

		// Add an extra padding to the minimumValueOfTopConstraint so we don't stick the bottom sheet to the content.
		let topOffset = minimumValueOfTopConstraint + Constants.offsetFromTop

		// Hide bottom sheet until further notice.
		topSheetConstraintToSuperviewTop.constant = DynamicBottomSheetPresentationManager.SnappingConstants.hiddenConstraintConstant
		tapBlockingViewTopConstraint.constant = DynamicBottomSheetPresentationManager.SnappingConstants.hiddenConstraintConstant

		// Since the maximum point to which the bottomSheet can be presented on the screen is defined by topOffset
		// and the constraint that is making the presentation possible is anchored to the superview.top, the height of the bottom sheet
		// cannot be bigger than view's height minus that topOffset.
		sheetHeightConstraint.constant = view.frame.height - topOffset
		_bottomSheetManager = DynamicBottomSheetPresentationManager(
			// Send the view since _it_ has the constraint that will need to be animated when snapping.
			containerView: view,
			constraintToTop: topSheetConstraintToSuperviewTop,
			sheetContent: _sheetContent,
			// Used to compute the topSheetConstraintToSuperviewTop values based on the dynamic size of the sheetContent.
			viewHeight: view.frame.height,
			topOffset: topOffset,
			minHeight: Constants.minHeight
		)
		// Intercept the delegate calls and manually forward them to our .presentationDelegate
		_bottomSheetManager?.delegate = self

		// Inform the concerned parties that the sheet will occupy this much space on the screen.
		_embeddedViewController.bottomSheetWillHave( minHeight: Constants.minHeight )

		// Make sure that if the delegate has been called _before_ the sheet has been setup, to satisfy the requests.
		if let initialState = initialState {
			_bottomSheetManager?.snap( to: initialState )

			// Clean-up to prevent any future possible errors.
			self.initialState = nil
		}
	}

	/// Snaps the bottom sheet to the specified state and updates the `initialState` for later usage if needed.
	/// - Parameters:
	///   - state: The state to which the bottom sheet should be snapped.
	///   - animationDuration: Custom animation duration for the `_bottomSheetManager` to perform the snapping action.
	///   - completion: Called after the animation is completed.
	private func snapBottomSheet( to state: SheetState, animationDuration: TimeInterval = Theme.Durations.standardAnimationDuration, completion: (() -> Void)? ) {
		if _bottomSheetManager == nil { initialState = state }
		_bottomSheetManager?.snap( to: state, animationDuration: animationDuration, completion: completion )
	}

	// MARK: - BottomSheetDelegate

	public func unhideBottomSheet( _ completion: (() -> Void)? ) {
		if _bottomSheetManager == nil { initialState = .partiallyDisplayed }
		// Use unhide since this might be called multiple times and we don't want to affect the appearance
		// unless the bottom sheet is actually hidden. Calling snap( to: .partiallyDisplayed ) might collapse
		// the bottom sheet.
		_bottomSheetManager?.unhide( completion: completion )
	}

	public func hideBottomSheet(_ completion: (() -> Void)?) {
		snapBottomSheet( to: .hidden, completion: completion )
	}

	public func collapseBottomSheet( animationDuration: TimeInterval, _ completion: (() -> Void)? ) {
		snapBottomSheet( to: .partiallyDisplayed, animationDuration: animationDuration, completion: completion )
	}

	public func expandBottomSheet( animationDuration: TimeInterval, _ completion: (() -> Void)? ) {
		snapBottomSheet( to: .fullyDisplayed, animationDuration: animationDuration, completion: completion )
	}
}

extension BottomSheetContainerViewController: BottomSheetPresentationDelegate {

	public func shouldScrollContentToTop() {
		// Forward the delegate call.
		presentationDelegate?.shouldScrollContentToTop()
	}

	public func sheetPositionWillChange( positioning: SheetPositioning ) {
		// Change the constant of the constraint that positions the tap blocking view.
		// Compute the blocking view constraint constant. The blocking view will go up to the top of the screen
		// in order to block the taps for the area that the bottom sheet doesn't cover, hance the min constant will be 0.
		let minConstant: CGFloat = 0
		let maxConstant = positioning.collapsedConstant
		tapBlockingViewTopConstraint.constant = positioning.percentage * (maxConstant - minConstant)

		// Forward the delegate call.
		presentationDelegate?.sheetPositionWillChange( positioning: positioning )
	}
}

extension BottomSheetContainerViewController: AnimatableContextProvider {
	
	public var graphicsContextView: UIView {
		// We are providing main view of this VC as a canvas for animation
		view
	}
}
