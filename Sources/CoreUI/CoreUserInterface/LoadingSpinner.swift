//
//  LoadingSpinner.swift
//  CoopM16
//
//  Created by Jens Willy Johannsen on 17/05/2016.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit

@IBDesignable private class AnimatedCircle: UIView, CAAnimationDelegate {
	var nextCircle: AnimatedCircle? {
		willSet {
			// If we are clearing the current nextCircle, set its .hasPreviousCircle to false first
			if nextCircle != nil && newValue == nil {
				nextCircle!.hasPreviousCircle = false	// Explicitly unwrapped: checked in the if-statement
			}
		}
		didSet {
			nextCircle?.hasPreviousCircle = true
		}
	}

	var hasPreviousCircle: Bool = false

	override init( frame: CGRect ) {
		super.init( frame: frame )
		privateInit()
	}

	required init?( coder aDecoder: NSCoder ) {
		super.init( coder: aDecoder )
		privateInit()
	}

	// tintColor property overridden so the background color is changed to match the tintColor
	override var tintColor: UIColor! {
		didSet {
			backgroundColor = tintColor
		}
	}

	func startAnimation( _ delay: CFTimeInterval? = nil ) {
		let scaleAnimation = CAKeyframeAnimation( keyPath: "transform.scale" )
		scaleAnimation.values = [ 1, 1.7, 1 ]
		scaleAnimation.keyTimes = [ 0, 0.4, 1.0 ]
		scaleAnimation.timingFunctions = [CAMediaTimingFunction( name: .easeInEaseOut ), CAMediaTimingFunction( name: .easeInEaseOut )]

		let opacityAnimation = CAKeyframeAnimation( keyPath: "opacity" )
		opacityAnimation.values = [ LoadingSpinner.Constants.smallCircleOpacity, LoadingSpinner.Constants.largeCircleOpacity, LoadingSpinner.Constants.smallCircleOpacity ]
		opacityAnimation.keyTimes = [ 0, 0.4, 1.0 ]
		opacityAnimation.timingFunctions = [CAMediaTimingFunction( name: .easeInEaseOut ), CAMediaTimingFunction( name: .easeInEaseOut )]

		let animationGroup = CAAnimationGroup()
		animationGroup.animations = [scaleAnimation, opacityAnimation]
		animationGroup.duration = LoadingSpinner.Constants.animationDuration
		animationGroup.delegate = self
		animationGroup.isRemovedOnCompletion = true

		// Add delay if we have it
		if let delay = delay {
			// Using the `convertTime(_:from:)` method converts the `CACurrentMediaTime()` into the current layer's local time
			animationGroup.beginTime = layer.convertTime( CACurrentMediaTime(), from: nil )  + delay
		}
		layer.add( animationGroup, forKey: "anim" )

		// If we have a "next circle", also restart its animation
		if let nextCircle = self.nextCircle {
			nextCircle.startAnimation( LoadingSpinner.Constants.nextCircleAnimationDelay + (delay ?? 0) )
		}
	}

	func stopAnimation() {
		layer.removeAllAnimations()
	}

	private func privateInit() {
		layer.cornerRadius = bounds.height/2
		backgroundColor = tintColor
		alpha = LoadingSpinner.Constants.smallCircleOpacity
	}

	func animationDidStop( _ anim: CAAnimation, finished flag: Bool ) {
		// Restart animation only if we don't have a previous circle (because that will be responsible for starting our animation) and we have a superview
		if let superview = superview, superview.alpha > 0 && !hasPreviousCircle {
			DispatchQueue.main.asyncAfter( deadline: .now() + LoadingSpinner.Constants.restartAnimationDelay ) {
				self.startAnimation()
			}
		}
	}
}

@IBDesignable public class LoadingSpinner: UIView {
	public struct Constants {
		static let animationDuration: CFTimeInterval = 0.55
		static let restartAnimationDelay: TimeInterval = 0.6
		static let nextCircleAnimationDelay: CFTimeInterval = 0.13

		/// Opacity values for small and large circles
		static let smallCircleOpacity: CGFloat = 0.5
		static let largeCircleOpacity: CGFloat = 1

		/// Corner radius of entire loading spinner
		static let cornerRadius: CGFloat = 6
		public static let defaultWidth: CGFloat = 90
		public static let defaultHeight: CGFloat = 30
	}

	private var _circle1: AnimatedCircle!
	private var _circle2: AnimatedCircle!
	private var _circle3: AnimatedCircle!

	/// `true` if the animation is ongoing.
	private(set) public var isAnimating: Bool = false

	override public var tintColor: UIColor! {
		didSet {
			_circle1.backgroundColor = tintColor
			_circle2.backgroundColor = tintColor
			_circle3.backgroundColor = tintColor
		}
	}

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

	override public var intrinsicContentSize: CGSize {
		let size = CGSize( width: bounds.height * 3, height: bounds.height )
		return size
	}

	public func animate() {
		// Start first circle's animation. It will start the next circles' animations
		_circle1.startAnimation()
		isAnimating = true
	}

	private func stopAnimating() {
		_circle1.stopAnimation()
		_circle2.stopAnimation()
		_circle3.stopAnimation()

		// Mark the flag so we know when to re-start the animation and when to not.
		isAnimating = false
	}
	
	public func hide( animated: Bool, completion: @escaping (_ finished: Bool) -> Void = { _ in } ) {
		// Hide the spinner if we're already animating or the alpha is different from 0.0.
		let hiddenAlpha: CGFloat = 0.0
		guard isAnimating || alpha != hiddenAlpha else {
			completion( true )
			return
		}
		
		if animated {
			let duration = Theme.Durations.standardAnimationDuration
			UIView.animate(withDuration: duration) {
				self.alpha = hiddenAlpha
			} completion: { finished in
				// Stop the animation and mark the flag.
				self.stopAnimating()

				// Call the completion once the animation is finished.
				completion( finished )
			}
		} else {
			alpha = hiddenAlpha
			stopAnimating()
			completion(true)
		}
	}

	/**
	Shows the loading spinner.

	- parameter animated:		Whether the appearance should be animated.
	- parameter afterDelay:		Delay before showing the spinner. Defaults to `0`.
	*/
	public func show( animated: Bool, afterDelay delay: TimeInterval = 0 ) {
		// Show the spinner if we're not animating or the alpha is different from 1.0.
		let visibleAlpha: CGFloat = 1.0
		guard !isAnimating || alpha != visibleAlpha else { return }

		// Stop any animations currently ongoing.
		stopAnimating()
		
		// Re-start the animation.
		if animated {
			let duration = Theme.Durations.standardAnimationDuration
			UIView.animate(withDuration: duration, delay: delay) {
				self.alpha = visibleAlpha
			} completion: { _ in
				// Start the animation once the view is fully visible.
				self.animate()
			}
		} else {
			alpha = visibleAlpha
			animate()
		}
	}

	// MARK: - Utils.

	private func privateInit() {
		layer.cornerRadius = Constants.cornerRadius

		// Create animated circles
		_circle1 = AnimatedCircle( frame: CGRect( x: bounds.height/4, y: bounds.height/4, width: bounds.height/2, height: bounds.height/2 ))
		_circle1.tintColor = colorsContent.primaryColor
		addSubview( _circle1 )

		_circle2 = AnimatedCircle( frame: CGRect( x: bounds.height/4 + bounds.height, y: bounds.height/4, width: bounds.height/2, height: bounds.height/2 ))
		_circle2.tintColor = colorsContent.primaryColor
		addSubview( _circle2 )
		_circle1.nextCircle = _circle2

		_circle3 = AnimatedCircle( frame: CGRect( x: bounds.height/4 + bounds.height * 2, y: bounds.height/4, width: bounds.height/2, height: bounds.height/2 ))
		_circle3.tintColor = colorsContent.primaryColor
		addSubview( _circle3 )
		_circle2.nextCircle = _circle3

		backgroundColor = .white
		layer.borderWidth = 1
		layer.borderColor = Theme.Colors.lightGray.withAlphaComponent(0.3).cgColor

		layer.shadowColor = Theme.Colors.lightGray.withAlphaComponent(0.8).cgColor
		layer.shadowOpacity = 0.5
		layer.shadowOffset = CGSize(width: 0, height: 3)
		layer.shadowRadius = 1
	}
}
