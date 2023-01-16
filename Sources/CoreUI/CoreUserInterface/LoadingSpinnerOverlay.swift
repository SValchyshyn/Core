//
//  LoadingSpinnerOverlay.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 18/05/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

/// Overlay view that contains in it's center a `LoadingSpinner` that facilitates blocking the UI when needed.
/// `.clear` background color, for now.
public final class LoadingSpinnerOverlay: UIView {
	/// Identifiers used for default added subviews.
	public enum AccessibilityIdentifiers {
		public static let loadingSpinnerBlockingView: String = "LoadingSpinnerBlockingView"
	}

	// MARK: - Properties.

	/// Actual `LoadingSpinner`.
	private lazy var _loadingSpinner: LoadingSpinner = {
		// Create the spinner and make it responsive to AutoLayout.
		// Also provide its real size using the frame because the `AnimatedCircles` will be added using frame positioning, not AutoLayout.
		let spinner: LoadingSpinner = .init( frame: .init( origin: .zero, size: .init( width: LoadingSpinner.Constants.defaultWidth, height: LoadingSpinner.Constants.defaultHeight ) ) )
		spinner.translatesAutoresizingMaskIntoConstraints = false

		// Add it as a subview and constrain it.
		addSubview( spinner )
		NSLayoutConstraint.activate( [
			spinner.centerXAnchor.constraint( equalTo: centerXAnchor ),
			spinner.centerYAnchor.constraint( equalTo: centerYAnchor ),
			spinner.widthAnchor.constraint( equalToConstant: LoadingSpinner.Constants.defaultWidth ),
			spinner.heightAnchor.constraint( equalToConstant: LoadingSpinner.Constants.defaultHeight )
		] )

		return spinner
	}()

	/// `true` if the overlay should capture all the interactions.`false` by default.
	public var isBlockingUserInteraction: Bool {
		get {
			return isUserInteractionEnabled
		}
		
		set {
			isUserInteractionEnabled = newValue
		}
	}
	
	public var spinnerColor: UIColor? {
		didSet { _loadingSpinner.tintColor = spinnerColor }
	}

	// MARK: - Custom init.

	override public init( frame: CGRect ) {
		super.init( frame: frame )
		privateInit()
	}

	required init?( coder aDecoder: NSCoder ) {
		super.init( coder: aDecoder )
		privateInit()
	}

	override public func prepareForInterfaceBuilder() {
		privateInit()
	}

	// MARK: - Public interface.

	public func hide( animated: Bool, completion: @escaping (_ finished: Bool) -> Void = { _ in } ) {
		_loadingSpinner.hide( animated: animated ) { finished in
			// Hide oneself so it doesn't continue to influence the view hierarchy.
			self.isHidden = true

			// Call the completion as well.
			completion( finished )
		}
	}

	/**
	Shows the loading spinner.

	- parameter animated:		Whether the appearance should be animated.
	- parameter afterDelay:		Delay before showing the spinner. Defaults to `0`.
	*/
	public func show( animated: Bool, afterDelay delay: TimeInterval = 0 ) {
		// Unhide oneself first.
		isHidden = false

		// Start the loading spinner animation.
		_loadingSpinner.show( animated: animated, afterDelay: delay )
	}

	// MARK: - Utils.

	private func privateInit() {
		// Access it so it's instantiated and added as a subview.
		_ = _loadingSpinner
		accessibilityIdentifier = AccessibilityIdentifiers.loadingSpinnerBlockingView
		backgroundColor = .clear
	}
}
