//
//  TopBarView.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 31/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit
import Log

@IBDesignable public class TopBarView: UIView {
	@IBInspectable public var title: String? {
		didSet {
			_titleLabel.text = title
		}
	}

	@IBInspectable public var showCloseButton: Bool = true {
		didSet {
			_closeButton.isHidden = !showCloseButton
		}
	}

	@IBInspectable public var showLeftButton: Bool = false {
		didSet {
			_leftButton.isHidden = !showLeftButton
		}
	}

	/// Optional left button icon, if `nil` we default to a back button icon
	@IBInspectable public var leftButtonIcon: UIImage? {
		didSet {
			// Update the button
			_leftButton.setImage( _leftButtonIcon, for: .normal )
		}
	}

	@IBInspectable public var showImage: Bool = false {
		didSet {
			_imageView.alpha = showImage ? 1 : 0
			_overlay.alpha = showImage ? 1 : 0
		}
	}

	/// If true, the title, close buttona and back button will be dark grey. Otherwise, they'll be white
	@IBInspectable public var useDarkElements: Bool = false {
		didSet {
			updateColors()
		}
	}

	/// Overwrite default title font.
	public var titleFont: UIFont? {
		didSet {
			_titleLabel.font = titleFont
		}
	}
	
	/// Overwrite default title alpha.
	public var titleAlpha: CGFloat = 1 {
		didSet {
			_titleLabel.alpha = titleAlpha
		}
	}
	
	/// Overwrite default leftButton `accessibilityLabel`.
	public var leftButtonAccessibilityLabel: String? {
		didSet { _leftButton.accessibilityLabel = leftButtonAccessibilityLabel }
	}

	public static var backgroundImageName: String? {
		didSet {
			if let backgroundImageName = TopBarView.backgroundImageName {
				// Image is set using UIImage( contentsOfFile: ) in order to _not_ use a cached version which has been flipped because it has been used as an OpenGL texture image.
				guard let path = Bundle.main.path( forResource: backgroundImageName, ofType: nil ) else {
					Log.technical.log(.error, "Unable to load TopBarView image from file", [.identifier("CoreUserInterface.TopBarView.backgroundImageName")])
					return
				}
				TopBarView.backgroundImage = UIImage( contentsOfFile: path )
			} else {
				TopBarView.backgroundImage = nil
			}
		}
	}
	public static var backgroundImage: UIImage?

	private var _imageView: UIImageView!	// Initialized in privateInit()
	private var _titleLabel: UILabel!		// Initialized in privateInit()
	private var _closeButton: CloseButton!		// Initialized in privateInit()
	private var _leftButton: UIButton!		// Initialized in privateInit()
	private var _overlay: UIView!			// Initialized in privateInit()

	private var _leftButtonIcon: UIImage? {
		// Need to do some bundle stuff for the interface builder in order to load images
		let bundle = Bundle( for: type( of: self ))
		// If we don't have a left button icon we default to a back button icon. We use different back icons according to the current configuration
		return leftButtonIcon ?? (useDarkElements ? UIImage( named: "gfx_back_dark", in: bundle, compatibleWith: self.traitCollection ) : UIImage( named: "gfx_back", in: bundle, compatibleWith: self.traitCollection ))
	}

	private struct Constants {
		/// Right X margin to close button
		static let rightButtonMargin: CGFloat = 0

		/// The minimum factor by which the text size can shrink in order to fit the width of the label.
		static let titleMinimumScaleFactor: CGFloat = 0.7

		/// Distance that the elements should have to the margins of the screen.
		static let elementsMargin: CGFloat = 16.0

		static let topBarHeight: CGFloat = 44
		static let barButtonSize: CGSize = CGSize( width: 60, height: 40 )

		static let titleLabelBottomPadding: CGFloat = 12
		static let barButtonBottomPadding: CGFloat = 2
	}

	public override init( frame: CGRect ) {
		super.init( frame: frame )
		privateInit()
	}

	public required init?( coder aDecoder: NSCoder ) {
		super.init( coder: aDecoder )
		privateInit()
	}

	/**
	Create UI
	*/
	private func privateInit() {
		// With the addition of iPhone X, we need to pin the bottom at 44 form safe area guideline top, and the title and buttons pinned from the bottom
		translatesAutoresizingMaskIntoConstraints = false
		
		// Deactivate the height constraint that's set in IB
		let heightConstraint = constraints.first { $0.firstAttribute == NSLayoutConstraint.Attribute.height }
		if let heightConstraint = heightConstraint {
			NSLayoutConstraint.deactivate([heightConstraint])
		}
		let guide = safeAreaLayoutGuide
		NSLayoutConstraint.activate([bottomAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.topBarHeight)])

		// Background image
		_imageView = UIImageView( frame: CGRect.zero )
		_imageView.translatesAutoresizingMaskIntoConstraints = false
		_imageView.contentMode = .top
		_imageView.image = TopBarView.backgroundImage
		insertSubview( _imageView, at: 0 )	// Place at bottom
		addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: ["imageView": _imageView as Any] ))
		addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: ["imageView": _imageView as Any] ))
		_imageView.alpha = 0

		// Semi-transparent black overlay
		_overlay = UIView( frame: CGRect.zero )
		_overlay.translatesAutoresizingMaskIntoConstraints = false
		_overlay.backgroundColor = colorsContent.overlayColor
		insertSubview( _overlay, aboveSubview: _imageView )
		addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "H:|[overlay]|", options: [], metrics: nil, views: ["overlay": _overlay as Any] ))
		addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:|[overlay]|", options: [], metrics: nil, views: ["overlay": _overlay as Any] ))
		_overlay.alpha = 0

		// Label
		_titleLabel = UILabel( frame: CGRect.zero )
		_titleLabel.translatesAutoresizingMaskIntoConstraints = false
		_titleLabel.textColor = UIColor.white
		_titleLabel.font = fontProvider.H5HeaderFont
		// Make the font adjustable.
		_titleLabel.adjustsFontSizeToFitWidth = true
		_titleLabel.minimumScaleFactor = Constants.titleMinimumScaleFactor
		insertSubview( _titleLabel, aboveSubview: _overlay )
		addConstraint( NSLayoutConstraint( item: _titleLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0 ))
		addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:[titleLabel]-\(Constants.titleLabelBottomPadding)-|", options: [], metrics: nil, views: ["titleLabel": _titleLabel as Any] ))

		// Button
		_closeButton = CloseButton( type: .custom )
		_closeButton.translatesAutoresizingMaskIntoConstraints = false
		_closeButton.isLight = !useDarkElements
		_closeButton.circleColor = UIColor.clear
		insertSubview( _closeButton, aboveSubview: _titleLabel )

		// Add identifier for UI testing.
		_closeButton.accessibilityIdentifier = "TopBarViewCloseButton"
		_closeButton.accessibilityLabel = CoreUserInterfaceLocalizedString("toolbar_close_action_accessibility_label")

		addConstraint( NSLayoutConstraint( item: _closeButton as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: Constants.barButtonSize.width ))
		addConstraint( NSLayoutConstraint( item: _closeButton as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: Constants.barButtonSize.height ))
		addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:[closeButton]-\(Constants.barButtonBottomPadding)-|", options: [], metrics: nil, views: ["closeButton": _closeButton as Any] ))
		addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "H:[button]-(margin)-|", options: [], metrics: ["margin": Constants.rightButtonMargin], views: ["button": _closeButton as Any] ))

		// Button
		_leftButton = UIButton( type: .custom )
		_leftButton.translatesAutoresizingMaskIntoConstraints = false

		// Set the left button icon, if we don't have one we default to a back button icon
		_leftButton.setImage( _leftButtonIcon, for: .normal )
		insertSubview( _leftButton, aboveSubview: _titleLabel )
		addConstraint( _titleLabel.leadingAnchor.constraint( greaterThanOrEqualTo: _leftButton.trailingAnchor, constant: 5.0 ) )

		// Add identifier for UI testing.
		_leftButton.accessibilityIdentifier = "TopBarViewLeftButton"
		_leftButton.accessibilityLabel = CoreUserInterfaceLocalizedString("toolbar_back_action_accessibility_label")

		addConstraint( NSLayoutConstraint( item: _leftButton as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: Constants.barButtonSize.width ))
		addConstraint( NSLayoutConstraint( item: _leftButton as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: Constants.barButtonSize.height ))
		addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:[_leftButton]-\(Constants.barButtonBottomPadding)-|", options: [], metrics: nil, views: ["_leftButton": _leftButton as Any] ))
		addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "H:|-(0)-[button]", options: [], metrics: nil, views: ["button": _leftButton as Any] ))
		_leftButton.isHidden = !showLeftButton

		if showImage {
			self.backgroundColor = UIColor.clear
		}

		self.clipsToBounds = true
		updateColors()
	}

	/**
	Adds the specified target/action to the close button's touch up inside action.

	- parameter target: The target of the action
	- parameter action: Selector to call
	*/
	public func addCloseButtonTarget( _ target: AnyObject?, action: Selector ) {
		_closeButton.addTarget( target, action: action, for: .touchUpInside )
	}

	/**
	Adds the specified target/action to the back button's touch up inside action.

	- parameter target: The target of the action
	- parameter action: Selector to call
	*/
	public func addBackButtonTarget( _ target: AnyObject?, action: Selector ) {
		_leftButton.addTarget( target, action: action, for: .touchUpInside )
	}

	/**
	Overrides the current left button and inserts the provided one in its place.

	- parameter button:	The button to be used from now on as a left button.
	- parameter size:	The size of the button which will be transformed into constraints.
	*/
	public func setLeftButtonOverride( _ button: UIButton, size: CGSize ) {
		// Clean-up the old button.
		_leftButton.removeFromSuperview()

		// Add it as a subview.
		addLeft( button: button, usingSizeAsConstraints: size )

		// Keep a reference to it.
		_leftButton = button
	}

	// MARK: - Private interface.

	/**
	Inserts the button as a subview and constrains is.

	- parameter button:	Will be added as a subview, above the title label. `accessibilityIdentifier = "TopBarViewLeftButton"`
	- parameter size:	Used to add with and height constraints.
	*/
	private func addLeft( button: UIButton, usingSizeAsConstraints size: CGSize ) {
		// Prevent the button using its autorezising mask as constraints since we're going to add constraints to the button.
		button.translatesAutoresizingMaskIntoConstraints = false
		insertSubview( button, aboveSubview: _titleLabel )

		// Add identifier for UI testing.
		button.accessibilityIdentifier = "TopBarViewLeftButton"

		// Constrain the button.
		_titleLabel.centerYAnchor.constraint( equalTo: button.centerYAnchor ).isActive = true
		// Prevent the button from overlapping with the title.
		_titleLabel.leadingAnchor.constraint( greaterThanOrEqualTo: button.trailingAnchor, constant: 10.0 ).isActive = true
		button.leadingAnchor.constraint( equalTo: leadingAnchor, constant: Constants.elementsMargin ).isActive = true
		button.heightAnchor.constraint( equalToConstant: size.height ).isActive = true
		// Prevent the button from going less than the provided size.
		button.widthAnchor.constraint( greaterThanOrEqualToConstant: size.width ).isActive = true
	}

	public override func prepareForInterfaceBuilder() {
		// Need to do some bundle stuff for the interface builder in order to load images
		let bundle = Bundle( for: type( of: self ))
		let image = UIImage( named: "dummy_top", in: bundle, compatibleWith: self.traitCollection)
		TopBarView.backgroundImage = image
		_imageView.alpha = 1
		_imageView.backgroundColor = backgroundColor

		// Set dummy background image
		privateInit()
		_titleLabel.text = title

		_closeButton.isLight = true
		_leftButton.setImage( _leftButtonIcon, for: .normal )
	}

	private func updateColors() {
		// Set the left button icon according to the current configuration
		_leftButton.setImage( _leftButtonIcon, for: .normal )

		// Update close button icon color
		_closeButton.isLight = !useDarkElements
		if useDarkElements {
			_closeButton.isLight = false
			_titleLabel.textColor = Theme.Colors.darkGray
		} else {
			_closeButton.isLight = true
			_titleLabel.textColor = .white
		}
	}
}
