//
//  ModalTransition.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 03/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

/// Mimics the system modal presentation transition, but should be only used when actually
/// `pushing` or `popping` a `UIViewController` within a `UINavigationController` stack.
/// If used to customize a `present` or `dismiss` the transition might not behave as expected due
/// to the behind the scenes implementation differences between `push` and `present` and between `pop` and `dismiss`.
public final class ModalTransition: NSObject, UIViewControllerAnimatedTransitioning {
	private enum Constants {
		/// Total duration of the animation.
		static let animationDuration: TimeInterval = 0.4
	}

	/// Enum for presentation _direction_
	public enum TransitionDirection {
		/// **Presentation** direction.
		case push

		/// **Dismissal** direction.
		case pop
	}

	// MARK: - Properties.

	/// `Push` or `Pop` transition?
	private let direction: TransitionDirection

	// MARK: - Init.

	public init( direction: TransitionDirection ) {
		self.direction = direction
		super.init()
	}

	// MARK: - UIViewControllerAnimatedTransitioning

	public func transitionDuration( using transitionContext: UIViewControllerContextTransitioning? ) -> TimeInterval {
		return Constants.animationDuration
	}

	public func animateTransition( using transitionContext: UIViewControllerContextTransitioning ) {
		// Get the views from the involved controllers
		guard
			let fromViewController = transitionContext.viewController( forKey: .from ),
			let toViewController = transitionContext.viewController( forKey: .to ),
			let toView = toViewController.view, let fromView = fromViewController.view else {
				// End the transition early if we were not able to create the prerequisites.
				transitionContext.completeTransition( false )
				return
		}

		// Get the container view
		let containerView = transitionContext.containerView
		let isPushing = direction == .push

		// Make sure the frame is the right size.
		toView.frame = transitionContext.finalFrame( for: toViewController )

		// Add the target's view to the container.
		containerView.addSubview( toView )

		if !isPushing {
			// If we're popping, make sure to send the toView to the back.
			containerView.sendSubviewToBack( toView )
		}

		// Determine the animation parameters.
		let fromTransform: CATransform3D = isPushing ? CATransform3DMakeTranslation( 0.0, fromViewController.view.frame.height, 0.0 ) : CATransform3DIdentity
		let toTransform: CATransform3D = isPushing ? CATransform3DIdentity : CATransform3DMakeTranslation( 0.0, toViewController.view.frame.height, 0.0 )
		let viewToAnimate: UIView = isPushing ? toView : fromView

		// Place the view according to the transform. When presenting send it off the screen, when dismissing do nothing.
		viewToAnimate.layer.transform = fromTransform

		// Animate the transition
		UIView.animate( withDuration: Constants.animationDuration, animations: {
			// Revert the previously added transform.
			viewToAnimate.layer.transform = toTransform
		}, completion: { _ in
			// End the transition.
			transitionContext.completeTransition( !transitionContext.transitionWasCancelled )
		})
	}
}
