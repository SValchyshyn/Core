//
//  BlobTransition.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 03/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

open class BlobTransition: NSObject, UIViewControllerAnimatedTransitioning {
	private enum Constants {
		/// Total duration of the transition.
		static let animationDuration: TimeInterval = 0.45
	}

	/// Holds information regarding the `BlobTransition` animation.
	public struct AnimationParameters {
		/// `.alpha` that a `view` that might be used to fade in/ out the content should have at the start of the animation.
		let startAlpha: CGFloat

		/// `.alpha` that a `view` that might be used to fade in/ out the content should have at the end of the animation.
		let endAlpha: CGFloat

		/// Color of the blob that we're animating from/ to. Should be used on the view that fades in/ out the content in order to blend-in.
		let blobColor: UIColor?

		/// `.transform` that the `mask view` which is used to give the circle expanding/ collapsing effect should have at the start of the animation.
		let startMaskTransform: CGAffineTransform

		/// `.transform` that the `mask view` which is used to give the circle expanding/ collapsing effect should have at the end of the animation.
		let endMaskTransform: CGAffineTransform
	}

	/// Enum for presentation _direction_
	public enum TransitionType {
		/// **Pushing** direction.
		case push

		/// **Popping** direction.
		case pop

		/// **Presentation** direction.
		case present

		/// **Dismissal** direction.
		case dismiss
	}

	// MARK: - Properties.

	/// Is it a _forward_ or _backwards_ transition?
	public var transitionType: TransitionType

	/// Holds the `frame` and the `color` of the blob we want to animate from/ to.
	private let _blobParams: BlobTransitionParameters

	/// Transform used to animate the mask's scale.
	private let _maskTransform: CGAffineTransform

	// MARK: - Init.

	public init( direction: TransitionType, params: BlobTransitionParameters ) {
		self.transitionType = direction
		self._blobParams = params

		let screenBounds: CGRect = UIScreen.main.bounds

		// Since the circle mask view must cover all the screen, in order to compute the scale factor
		// we must find the biggest distance between the blobFrame.center and the toView's corners.
		let blobCenter: CGPoint = .init( x: _blobParams.frame.midX, y: _blobParams.frame.midY )
		let topLeftCorner: CGPoint = screenBounds.origin
		let topRighCorner: CGPoint = .init( x: screenBounds.maxX, y: screenBounds.origin.y )
		let bottomRightCorner: CGPoint = .init( x: screenBounds.maxX, y: screenBounds.maxY )
		let bottomLeftCorner: CGPoint = .init( x: screenBounds.origin.x, y: screenBounds.maxY )

		// Determine what is the maximum distance.
		let maxDistanceToCorners: CGFloat = [
			topRighCorner.distance( to: blobCenter ),
			bottomRightCorner.distance( to: blobCenter ),
			bottomLeftCorner.distance( to: blobCenter ),
			topLeftCorner.distance( to: blobCenter ) ].max()! // Only returns nil if the array is empty. Not the case here. -FAIO

		// Since the mask is going to be a circle, the maxDistanceToCorners is basically the new radius
		// of the circle that is big enough for the screen to fully fit inside.
		// The scale factor will be the new radius divided by the current radius of the blob (which is half of its width/ height, as the blob should be a circle)
		let maskScaleFactor = maxDistanceToCorners / ( _blobParams.frame.width / 2 )

		// Create the scale transform we're going to use for the animation.
		self._maskTransform = .init( scaleX: maskScaleFactor, y: maskScaleFactor )

		super.init()
	}

	// MARK: - UIViewControllerAnimatedTransitioning method implementation.

	public func transitionDuration( using transitionContext: UIViewControllerContextTransitioning? ) -> TimeInterval {
		return Constants.animationDuration
	}

	public func animateTransition( using transitionContext: UIViewControllerContextTransitioning ) {
		// Get the views from the involved controllers.
		guard
			let toViewController = transitionContext.viewController( forKey: .to ),
			let fromViewController = transitionContext.viewController( forKey: .from ),
			let fromView = fromViewController.view,
			let toView = toViewController.view else {
				// Unable to get from/ to view for blob transition.
				transitionContext.completeTransition( false )
				return
		}

		// Manually set the frame of the `toView` since, somehow when the toViewController is defined in its own `xib` it doesn't know how to automatically set it's final frame.
		// inspired by: https://stackoverflow.com/a/42614444
		toView.frame = transitionContext.finalFrame( for: toViewController )

		// Determine the parameters and views involved in the transition based on the direction of the transition.
		let isTransitioningForward = transitionType == .push || transitionType == .present
		let transparentAlpha: CGFloat = 0.0
		let opaqueAlpha: CGFloat = 1.0
		let parameters: AnimationParameters = .init( startAlpha: isTransitioningForward ? opaqueAlpha : transparentAlpha, 	// If we're isPushing, we want the fadingView to be visible at first
													 endAlpha: isTransitioningForward ? transparentAlpha : opaqueAlpha, 		// and non-visible at the end of the animation. The opposite otherwise.
													 blobColor: _blobParams.color,
													 startMaskTransform: isTransitioningForward ? .identity : _maskTransform, // If we're isPushing, we want the maskView to be as big as the blob
													 endMaskTransform: isTransitioningForward ? _maskTransform : .identity )	// and big enough to cover the whole screen at the end of the animation. The opposite otherwise.

		// Prepare the animation based on the transition type. Certain transitions require different setup.
		prepare( for: transitionType, fromView: fromView, toView: toView, context: transitionContext )

		animateTransition( underlyingView: isTransitioningForward ? fromView : toView, 	// If we're transitioning forward, we want the source view to be under in order to animate on top of it.
			topView: isTransitioningForward ? toView : fromView, 						// If we're transitioning forward, we want the source view to be on top so we can animate it out over the destination view.
			blobFrame: _blobParams.frame,
			animationParameters: parameters ) { _ in
				// Finish the transition.
				transitionContext.completeTransition( !transitionContext.transitionWasCancelled )
		}
	}

	/**
	Animates the transition between the two views of the viewControllers involved in the transition.
	1. Adds a view in the `topView` that will be either faded in/ out while transitioning. This is done so when the transition is a `push`, the content of the `topView` will be covered by a view that has the same color as the blob,
	allowing us to overlap it perfectly over the blob. When `popping`, the content will be fully visible, but it will fade in to the color of the blob, also, overlapping perfectly over the blob.
	2. Attributes the `maskView` as the `.mask` property on the `topView`.
	This will allow us to  limit the bounds that the content of the `topView` is visible to the bounds defined by the `maskView`, hence creating the circle view.
	In order to give the expanding/ collapsing impression, we will animate the scale of the `maskView`. When making it bigger, more of the contents of the `topView` will be seen.
	Same in the other direction, more we collapse it, less of the contents are visible.

	Combining the mask and the fade we will have the following results:

	• when `pushing`, the `topView` (the destination view) will be the same size as the blob, same color. During the transition it will then expand and the color will slowly fade out.

	• when `popping`, the `topView` (this time the source view) will have its full size. During the transition will then collapse and the color will slowly fade in so it will perfectly overlap with the blob.

	- parameter underlyingView:			The `UIViewController.view` of one of the viewControllers involved in the transition that should always be under.
								Should be one of `transitionContext.view( forKey: .to )` or `transitionContext.view( forKey: .from )`, depending on the direction of the transition.
	- parameter topView:				The `UIViewController.view` of one of the viewControllers involved in the transition that should always be on top.
								Should be one of `transitionContext.view( forKey: .to )` or `transitionContext.view( forKey: .from )`, depending on the direction of the transition.
	- parameter blobFrame:				The frame of the blob from which the circular animation should begin from.
	- parameter animationParameters:	Contain `start` and `end` values for the entities involved in the animation.
	- parameter completion:				Called at the end of the animation. If method is overriden, **MUST** be called under any circumstance.
	*/
	open func animateTransition( underlyingView: UIView, topView: UIView, blobFrame: CGRect, animationParameters: AnimationParameters, completion: @escaping ((Bool) -> Void) ) {
		// Fade view, used to slowly show/ hide the content of the topView in the animation process.
		let fadeView: UIView = .init( frame: topView.frame )
		// Make it the same color as the blob so it will overlap perfectly, color-wise.
		fadeView.backgroundColor = animationParameters.blobColor

		// Mask view used to create the expanding/ collapsing blob effect. Always make it as big as the blob.
		// It's size will be changed using the `.transform` property.
		let maskView: UIView = .init( frame: blobFrame )
		maskView.layer.cornerRadius = blobFrame.width / 2
		// The color doesn't matter as long as it's fully opaque. Alpha channels on a mask view will make content not visible through it.
		maskView.backgroundColor = .black

		// Set the transform on the mask so we can animate it expanding/ collapsing.
		maskView.transform = animationParameters.startMaskTransform

		// Set the alpha of the fadeView.
		fadeView.alpha = animationParameters.startAlpha

		// Add the fadeView as a subview so we can slowly fade out/ int the content while the mask is scaling up/ down.
		topView.addSubview( fadeView )

		// Add the mask to the topView so we can either animate it expanding or collapsing.
		topView.mask = maskView

		// Animate the transition.
		UIView.animate( withDuration: Constants.animationDuration, animations: {
			// Make the mask big enough so there is no part of the screen not masked in order to make the toView fully visible.
			maskView.transform = animationParameters.endMaskTransform

			// Slowly fade the alpha.
			fadeView.alpha = animationParameters.endAlpha
		}, completion: { finished in
			// Clean-up.
			fadeView.removeFromSuperview()
			topView.mask = nil

			// Forward the completion.
			completion( finished )
		} )
	}

	// MARK: - Utils.

	/**
	Makes all the preparations before the animation of the transition begins.
	This is necessary because some transitioning types require different `UIViewControllerContextTransitioning` setup beforehand and some don't.

	- parameter transition:			Used to determine what setup we have to do.
	- parameter fromView:			The viewController's view _from_ which we're transitioning.
	- parameter toView:				The viewController's view _to_ which we're transitioning.
	- parameter context:			The context object containing information about the transition.
	*/
	private func prepare( for transition: TransitionType, fromView: UIView, toView: UIView, context: UIViewControllerContextTransitioning ) {
		switch transition {
		case .present, .push:
			// If we're transitioning forward, add the new viewController's view in the hierarchy no matter the
			context.containerView.addSubview( toView )

		case .pop:
			// If we're popping the viewController, we also have to add the toView in the view hierarchy,
			// otherwise we will end up with a black screen. It's just how underlyingly transitioning using a UINavigationController or by presenting
			// a new viewController works. Somehow, when transitioning forward using a UINavigationController, the toView is not kept in the transitionContext.containerView
			// while when transitioning forward using `present` the toView along with the view hierarchy is kept under the presented viewController.
			context.containerView.insertSubview( toView, at: 0 )

		case .dismiss:
			// The view we're transitioning to is still visible in the view hierarchy, don't do anything for now.
			break
		}
	}
}
