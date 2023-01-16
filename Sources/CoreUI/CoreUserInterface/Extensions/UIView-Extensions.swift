//
//  UIView-Extensions.swift
//  CoreUserInterface
//
//  Created by Frederik Sørensen on 29/11/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

public extension UIView {
	/// Shows the loading spinner.
	///
	/// - Parameters:
	///   - animated: Whether the appearance should be animated.
	///   - isModal: `true` if all user interaction is blocked until the loading spinner is removed again. Defaults to `false`.
	///   - color: Spinner main color, leave blank for default.
	///
	/// !WARNING!
	/// If `isModal: true` only the `view` on which this method is called will be blocked. If the intention is to block the whole screen
	/// please make sure to call this from the appropriate `view`. e.g. `tabBarController.view`/ `navigationController.view`.
	func showLoadingSpinner( animated: Bool, isModal: Bool = false, color: UIColor? = nil ) {
		// Make sure that we're on the main thread.
		guard Thread.isMainThread else {
			// Otherwise, dispatch to it.
			DispatchQueue.main.async { self.showLoadingSpinner( animated: animated, isModal: isModal ) }
			return
		}

		// Setup the spinner.
		let spinnerOverlay: LoadingSpinnerOverlay
		if let spinner = findLoadingSpinner() {
			// We already have a spinner in the view hierarchy, use it.
			spinnerOverlay = spinner
		} else {
			// We don't have a spinner in the view hierarchy, create a new one.
			spinnerOverlay = .init()
			spinnerOverlay.translatesAutoresizingMaskIntoConstraints = false

			// Add the blockingView as a subview and make sure it's always on top.
			addSubview( spinnerOverlay )
			spinnerOverlay.pinEdges( to: self )
		}

		// Make sure it's always on top.
		bringSubviewToFront( spinnerOverlay )

		// Block or unblock the user interaction.
		spinnerOverlay.isBlockingUserInteraction = isModal

		// Start the spinner animation.
		if let color = color {
			spinnerOverlay.spinnerColor = color
		}
		spinnerOverlay.show( animated: animated )
	}

	/// Hides the loading spinner. Thread-safe: dispatches to the main thread.
	///
	/// - Parameters:
	///   - animated: Whether the hiding should be animated.
	///   - removeFromSuperview: Whether the loading spinner should be removed from its superview. Defaults to `true`.
	func hideLoadingSpinner( animated: Bool, andRemoveFromSuperview removeFromSuperview: Bool = true ) {
		// Make sure that we're on the main thread.
		guard Thread.isMainThread else {
			// Otherwise, dispatch to it.
			DispatchQueue.main.async { self.hideLoadingSpinner( animated: animated, andRemoveFromSuperview: removeFromSuperview ) }
			return
		}

		// Make sure we can find it in the view hierarchy.
		guard let spinnerOverlay = findLoadingSpinner() else { return }

		// Hide the spinner.
		spinnerOverlay.hide( animated: animated ) { _ in
			// Should we also remove it from the superview?
			guard removeFromSuperview else { return }

			// Yes.
			spinnerOverlay.removeFromSuperview()
		}
	}

	// MARK: - Utils.

	/// Iterates through the `subviews` in search of a `UIView` with its `accessibilityIdentifier` equal to `LoadingSpinnerOverlay.AccessibilityIdentifiers.loadingSpinnerBlockingView`.
	private func findLoadingSpinner() -> LoadingSpinnerOverlay? {
		// Find the LoadingSpinner container.
		return subviews
			.first { $0.accessibilityIdentifier == LoadingSpinnerOverlay.AccessibilityIdentifiers.loadingSpinnerBlockingView } as? LoadingSpinnerOverlay
	}

	// MARK: - Nib loading

	/**
	Load a view from a NIB with the same name and add it as a subview pinned to the edges of the current view.
	*/
	@discardableResult func loadFromNib<T: UIView>() -> T? {
		guard let contentView = Bundle( for: type( of: self )).loadNibNamed( String( describing: type( of: self )), owner: self, options: nil )?.first as? T else {
			return nil
		}
		self.addSubview( contentView )
		contentView.pinEdges( to: self )
		return contentView
	}
	
	/// Round specific corners for view.
	/// - Parameters:
	///   - corners: `UIRectCorner` value. The corners of a rectangle.
	///   - radius: `CGFloat` value. Corner radius.
	func applyRoundedCorners( corners: UIRectCorner, radius: CGFloat ) {
		 let path = UIBezierPath( roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius) )
		 let mask = CAShapeLayer()
		 mask.path = path.cgPath
		 layer.mask = mask
	 }
	
	/// Draw bottom shadow.
	/// - Parameters:
	///   - opacity: The opacity of the shadow. Default is 0.5. Value should be in range [0, 1]
	///   - radius: The blur radius used to create the shadow. Default is 4.0.
	///   - color: The color of the shadow. Default is UIColor.gray.
	///   - offset: The shadow offset. Defaults to (0, 2).
	func applyBottomShadow(opacity: Float = 0.5, radius: CGFloat = 4.0, color: UIColor = .gray, offset: CGSize = CGSize(width: 0, height: 2)) {
		layer.masksToBounds = false
		layer.shadowOpacity = opacity
		layer.shadowRadius = radius
		layer.shadowColor = color.cgColor
		layer.shadowOffset = offset
		layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
													 y: bounds.maxY - layer.shadowRadius,
													 width: bounds.width,
													 height: layer.shadowRadius)).cgPath
	}

	/// Pins edges of the view to the edges of the provided parent view with the corresponding paddings.
	///
	/// - Parameters:
	///   - parent: The parent view to which the current view will be pinned.
	///   - top: The padding to the top edge of the parent view.
	///   - left: The padding to the left edge of the parent view.
	///   - bottom: The padding to the bottom edge of the parent view.
	///   - right: The padding to the right edge of the parent view.
	func pinEdges(to parent: UIView, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
		NSLayoutConstraint.activate([
			topAnchor.constraint(equalTo: parent.topAnchor, constant: top),
			leftAnchor.constraint(equalTo: parent.leftAnchor, constant: left),
			parent.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom),
			parent.rightAnchor.constraint(equalTo: rightAnchor, constant: right)
		])
	}
	
	// MARK: Shadow
	
	/// https://stackoverflow.com/questions/34269399/how-to-control-shadow-spread-and-blur
	// swiftlint:disable:next function_parameter_count - keeping the x and y names to match Sketch more closely -MACO
	func applyShadow(color: UIColor, alpha: Float, x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat) {
		layer.shadowColor = color.cgColor
		layer.shadowOpacity = alpha
		layer.shadowOffset = CGSize(width: x, height: y)
		layer.shadowRadius = blur / 2.0
		if spread == 0 {
			layer.shadowPath = nil
		} else {
			let rect = bounds.insetBy(dx: -spread, dy: -spread)
			layer.shadowPath = UIBezierPath(rect: rect).cgPath
		}
	}
	
}

public extension UIAppearance where Self: UIView {
	
	/// Instantiates a view from an XIB with the same name as the class.
	///
	/// Set both File's Owner and the root view to the custom class.
	/// Connect IBOutlets to the _root view_ and not to the File's Owner.
	static func loadFromNib() -> Self {
		let nibName = String(describing: self)
		let nib = UINib(nibName: nibName, bundle: Bundle(for: self))
		// swiftlint:disable:next force_cast_gp
		return nib.instantiate(withOwner: self, options: nil).first as! Self
	}
	
}
