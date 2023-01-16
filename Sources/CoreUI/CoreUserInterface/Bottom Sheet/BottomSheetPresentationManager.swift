//
//  BottomSheetPresentationManager.swift
//  CoopM16
//
//  Created by Coruț Fabrizio on 19/09/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

public protocol BottomSheetPresentationDelegate: AnyObject {

	/// Used to notify that the `UIScrollView` from the panned container should be scrolled to top due to a snapping state change.
	func shouldScrollContentToTop()

	/// Called when the `topContainerConstraint.constant` value will change. This gives the opportunity for the delegate to act upon the change
	/// and perform any other UI customizations that will be performed in sync with the bottom sheet.
	/// - Parameter positioning: Contains values based on which the `bottomSheet` is being manipulated.
	func sheetPositionWillChange( positioning: SheetPositioning )
	
	/// Called when the `topContainerConstraint.constant` value changed.
	func sheetPositionDidChange()
}

public extension BottomSheetPresentationDelegate {
	func sheetPositionWillChange(positioning: SheetPositioning) {}
	func sheetPositionDidChange() {}
}

/// Encapsulates the logic for creating a `bottom sheet` effect using the `UIScrollViewDelegate` method callbacks
/// and a constraint to the view/ container view which should be the `bottom sheet`.
/// Usage :
/// 	should be the sole `UIScrollViewDelegate` of the `UIScrollView`
///		or
///		the following methods should be called manually:
///			func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
///			func scrollViewDidScroll(_ scrollView: UIScrollView)
///			func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
///			func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
open class BottomSheetPresentationManager: NSObject, UIScrollViewDelegate {
	struct Constants {
		/// Threhold under which we will consider the velocity `0.0`.
		static let velocityThreshold: CGFloat = 0.04
	}

	/// Used to animate to the new snap position.
	private var _parameters: SnapParameters

	/// A mapping between each state and the configuration that should be used to define the state.
	private var _stateMapping: [SheetState: SheetSnapConfiguration] = [:]

	/// Defines the current presentation state in which the controlled sheet is in.
	public private(set) var state: SheetState = .partiallyDisplayed

	/// `true` if the `_topContainerConstraint.constant` should be altered in order to switch between states.
	private var _shouldPanContainer: Bool = false

	/// Used to determine the `partiallyDisplayed` state configuration.
	private var _partiallyDisplayedConfiguration: SheetSnapConfiguration

	/// Used to determine the `fullyDisplayed` state configuration.
	private var _fullyDisplayedConfiguration: SheetSnapConfiguration

	/// Used to determine when to start the container pan effect.
	private let _startingOffset: CGPoint

	/// Constraint used to create the bottom sheet effect upon scroll.
	private let _topContainerConstraint: NSLayoutConstraint

	/// View in which the container is a subview. Used for `.layoutIfNeeded()` during the snapping animation.
	private let _view: UIView

	/// The view to which the `UIPanGestureRecognizer` has been added to.
	private weak var _panningView: UIView?

	/// `true` if we're performing a snapping animation.
	private var _panningInProgress: Bool = false

	// MARK: - Public interface.

	/// Damping of the spring effect of the snapping animation. Default to `0.8`.
	/// To smoothly decelerate the animation without oscillation, use a value of 1. Employ a damping ratio closer to zero to increase oscillation.
	var springDamping: CGFloat = 0.8

	/// Used to request information about scrollView's content offset. The panning effect of the container should not be allowed if the contentOffset.
	public weak var delegate: BottomSheetPresentationDelegate?

	// MARK: - Init.

	/**
	Handles the presentation and dismissal of a bottom-sheet-like contained `UIViewController` through `UIScrollViewDelegate` delegate methods.
	Handles only transition between two states: visible and partially visible.
	Assumes that: the starting state is the partially visible one, that the content of the bottom-sheet is a class or subclass of `UIScrollView` `and` that
			the constraint constants are always positive.

	- parameter topContainerConstraint:				Top constraint of the container view that should represent the bottom sheet.
	- parameter view: 								The `UIView` in which the container is a subview. Used for `.layoutIfNeeded()` during the snapping animation.
	- parameter stateMapping:						A mapping between all the possible `SheetStates` and their `SheetSnapConfigurations`. Values for `.fullyDisplayed`, `.partiallyDisplayed` and `startingState` are mandatory.
	- parameter startingScrollViewContentOffset:	The `contentOffset` at which the content of the bottom sheet can be found.
	- parameter startingState:						The `SheetState` in which we wish to start the presentation from.
	- returns:										`nil` if `stateMapping` doesn't contain all configurations for all states.
	*/
	public init?( topContainerConstraint: NSLayoutConstraint, view: UIView, stateMapping: [SheetState: SheetSnapConfiguration], startingScrollViewContentOffset: CGPoint, startingState: SheetState ) {
		// Make sure we have the configurations for each used state.
		guard let currentStateSnapConfiguration = stateMapping[startingState],
			let fullyDisplayedStateConfiguration = stateMapping[.fullyDisplayed],
			let partiallyDisplayedStateConfiguration = stateMapping[.partiallyDisplayed] else { return nil }

		_topContainerConstraint = topContainerConstraint
		_view = view
		_stateMapping = stateMapping
		_startingOffset = startingScrollViewContentOffset
		_parameters = .init( snapConstant: currentStateSnapConfiguration.constraintConstant, flingVelocity: .zero )
		_partiallyDisplayedConfiguration = partiallyDisplayedStateConfiguration
		_fullyDisplayedConfiguration = fullyDisplayedStateConfiguration
		state = startingState
	}

	/// Updates the parameters based on which the snapping is performed.
	/// - Parameter stateMapping: Will be merged with the current mapping and all the missing mapping will be kept. The others will be updated.
	public func update( stateMapping: [SheetState: SheetSnapConfiguration] ) {
		// Merge the two mappings, solving conflicts by choosing the updated mapping.
		let newMapping = _stateMapping.merging( stateMapping, uniquingKeysWith: { $1 } )

		// Make sure we have the configurations for each used state.
		guard let currentStateSnapConfiguration = newMapping[state],
			let fullyDisplayedStateConfiguration = newMapping[.fullyDisplayed],
			let partiallyDisplayedStateConfiguration = newMapping[.partiallyDisplayed] else { return }

		_stateMapping = newMapping
		_parameters = _parameters.updating( snapConstant: currentStateSnapConfiguration.constraintConstant )
		_partiallyDisplayedConfiguration = partiallyDisplayedStateConfiguration
		_fullyDisplayedConfiguration = fullyDisplayedStateConfiguration

		// Reflect the changes by snapping based on the current state.
		animateSnapping()
	}

	/// - returns:		`true` if we can pan the container externally due to some scrolling events. We should prevent this while the container is hidden.
	public func shouldPanContainerAtScroll() -> Bool {
		return state != .hidden && !_panningInProgress
	}

	/**
	Adds a `UIPanGestureRecognizer` to the view, making it able to pan the whole container from it.

	- parameter view:		The view from which we want to pan the container.
	*/
	public func addPanGestureRecognizer( to view: UIView ) {
		// Add a `UIPanGestureRecognizer` to the provided view.
		let panGestureRecognizer = UIPanGestureRecognizer( target: self, action: #selector(panActionHandler(_:)) )
		view.addGestureRecognizer( panGestureRecognizer )

		// Keep a reference to the view so we can
		_panningView = view
	}

	/**
	Snaps the container based on the current state or the provided `state`.
	If no `state` is provided, the snapping behaviour will be a toggle between `.partiallyDisplayed` and `.fullyDisplayed`,
	Also makes the feed `.partiallyDisplayed` if the current state is `.hidden`.

	- parameter state:		Specific `.state` to which to snap.
	- parameter completion:	Called after the snapping is finished.
	*/
	open func snap( to state: SheetState? = nil, animationDuration: TimeInterval = Theme.Durations.standardAnimationDuration, completion: (() -> Void)? = nil ) {
		// Compute the state by hand, here.
		let newSnapConstant: CGFloat
		// Do we have a specific state in which we must snap to?
		if let newState = state {
			// Make sure we're snapping to a different state than the current one.
			guard newState != self.state else {
				completion?()
				return
			}

			// YES: Override the toggling snap logic.
			switch newState {
			case .partiallyDisplayed:
				// We want to partially close the feed.
				newSnapConstant = _partiallyDisplayedConfiguration.constraintConstant
				self.state = .partiallyDisplayed

			case .fullyDisplayed:
				// We want to fully display the feed.
				newSnapConstant = _fullyDisplayedConfiguration.constraintConstant
				self.state = .fullyDisplayed

			case .hidden:
				if let snapConstant = _stateMapping[.hidden]?.constraintConstant {
					newSnapConstant = snapConstant
					self.state = .hidden
				} else {
					completion?()
					return
				}
			}
		} else {
			// NO: Just toggle between .partiallyDisplayed and .fullyDisplayed states and unhide, if neccessary.
			switch self.state {
			case .partiallyDisplayed:
				// We want to fully display the feed.
				newSnapConstant = _fullyDisplayedConfiguration.constraintConstant
				self.state = .fullyDisplayed

			case .fullyDisplayed:
				// We want to partially close the feed.
				newSnapConstant = _partiallyDisplayedConfiguration.constraintConstant
				self.state = .partiallyDisplayed

			case .hidden:
				// We want the feed to be partially visible.
				newSnapConstant = _partiallyDisplayedConfiguration.constraintConstant
				self.state = .partiallyDisplayed
			}
		}

		// Update the snap parameters with the new values. Provide .zero fling velocity since we're not dragging it ourselves.
		_parameters = .init( snapConstant: newSnapConstant, flingVelocity: .zero )

		// Make the content scroll to the top.
		delegate?.shouldScrollContentToTop()

		// Animate with the new values.
		animateSnapping( animationDuration: animationDuration, completion: completion )
	}

	/**
	Unhides the container.

	- parameter completion:	Called after the snapping is finished.
	*/
	public func unhide( completion: (() -> Void)? = nil ) {
		guard state == .hidden else { return }

		// We want the feed to be partially visible.
		state = .partiallyDisplayed

		// Update the snap parameters with the new values. Provide .zero fling velocity since we're not dragging it ourselves.
		_parameters = .init( snapConstant: _partiallyDisplayedConfiguration.constraintConstant, flingVelocity: .zero )

		// Make the content scroll to the top.
		delegate?.shouldScrollContentToTop()

		// Animate with the new values.
		animateSnapping( completion: completion )
	}

	/**
	Hides the container.

	- parameter completion:	Called after the snapping is finished.
	*/
	public func hide( completion: (() -> Void)? = nil ) {
		// Make sure we have the configuration for the hidden state.
		guard let hiddenConfiguration = _stateMapping[.hidden] else { return }

		// Manually set the new hiding values.
		// Update the snap parameters with the new values. Provide .zero fling velocity since we're not dragging it ourselves.
		_parameters = .init( snapConstant: hiddenConfiguration.constraintConstant, flingVelocity: .zero )
		state = .hidden

		// Make the content scroll to the top.
		delegate?.shouldScrollContentToTop()

		// Animate with the new values.
		animateSnapping( completion: completion )
	}

	// MARK: - UIScrollViewDelegate method implementation.

	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		// Set the flag so we prevent any external changes to the container constraint.
		_panningInProgress = true

		// Only alow panning of the container view if we started scrolling from
		// the origin of the content or if we're overshooting.
		if scrollView.contentOffset.y <= _startingOffset.y {
			_shouldPanContainer = true
		} else {
			// Remove the flag if we're starting the scroll from a different prosition.
			_shouldPanContainer = false
		}
	}

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// Determine wether we're scrolling to dismiss, or to fullyDisplayed.
		let isScrollingToDismiss = _shouldPanContainer && scrollView.contentOffset.y < _startingOffset.y
		let isScrollingToOpen = _shouldPanContainer && scrollView.contentOffset.y > _startingOffset.y
		let shouldAllowPan = isScrollingToOpen || isScrollingToDismiss

		// Only modify the constraint if we're allowed to pan.
		guard shouldAllowPan else { return }

		// Since the contentOffset is always reset to 0.0 while panning
		// the delta will always be the negative value of the contentOffset.
		let delta = -scrollView.contentOffset.y

		// Create the pan effect.
		pan( delta, scrollView: scrollView )
	}

	public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		// Prevent doing any changes while the constraints are outside of the two snap points.
		if _topContainerConstraint.constant <= _fullyDisplayedConfiguration.constraintConstant || _topContainerConstraint.constant >= _partiallyDisplayedConfiguration.constraintConstant {
			// There is a special case which we have to take into consideration: overshooting while panning.
			if _topContainerConstraint.constant == _fullyDisplayedConfiguration.constraintConstant && _shouldPanContainer && targetContentOffset.pointee.y > 0 {
				// Reset the panning flag so it's not accidentally used on gesture recognizer panning.
				_shouldPanContainer = false

				// Update the new snap parameters according to the scrolling velocity.
				updateSnapParameters( velocity )

				// We're overshooting upwards, either by dragging or flinging. Allow the logic so we can snap to the new state.
				// And also allow the dragging effect to take place so we do not reset the contentOffset after snapping.
				return
			} else if _topContainerConstraint.constant >= _partiallyDisplayedConfiguration.constraintConstant && _shouldPanContainer {
				// We're overshooting downwards, either by dragging or flinging. Allow the logic so we can snap to the new state.

				// Reset the panning flag so it's not accidentally used on gesture recognizer panning.
				_shouldPanContainer = false
			} else {
				// Allow the scroll, no special conditions have been met.
				// Also, do not update the snap parameters either.
				return
			}
		}

		// Update the new snap parameters according to the scrolling velocity.
		updateSnapParameters( velocity )

		// We should prevent the scroll while snapping by setting the targetContentOffset to the current contentOffset
		// because we don't want the scrolling to go simultaneously along with the pan. This would create a weird effect.
		targetContentOffset.pointee = scrollView.contentOffset
	}

	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		// Make sure we have topConstraint to animate.
		guard _parameters.snapConstant != _topContainerConstraint.constant else { return }

		// Make the scroll indicators flash so they do not remain displayed.
		scrollView.flashScrollIndicators()

		// Start the animation.
		animateSnapping()
	}

	// MARK: - Utils.

	/**
	Pans the container and prevents the `UIScrollView` from scrolling.

	- parameter delta:			The scroll difference. Used to compute the new constraint constant.
	- parameter scrollView:		Used to stop the scrolling while panning.
	*/
	private func pan( _ delta: CGFloat, scrollView: UIScrollView? = nil ) {
		// Don't let the constraint go under the value.
		let newConstraintValue = max( _fullyDisplayedConfiguration.constraintConstant, _topContainerConstraint.constant + delta )

		// Make sure we're actually creating a new value and not assigning an old one.
		guard newConstraintValue != _topContainerConstraint.constant else { return }

		// Prevent the scrollView from actually scrolling so the container and the scroll view move at the same time.
		scrollView?.setContentOffset( .zero, animated: false )

		// Update the constraint with the new computed value.
		updateConstraint( to: newConstraintValue )
	}

	/**
	Updates the `state` and `constraint constant` of the container based on the `velocity`.

	- parameter velocity: 				The velocity of the scroll view (in points) at the moment the touch was released.
	*/
	private func updateSnapParameters( _ velocity: CGPoint ) {
		// Velocity == 0 => finger was lifted without flinging.
		let newSnapConstant: CGFloat
		guard velocity.y != 0 else {
			switch state {
			case .partiallyDisplayed:
				if _topContainerConstraint.constant <= _partiallyDisplayedConfiguration.constraintConstant - _partiallyDisplayedConfiguration.threshold {
					// We lifted the finger while the container was panned in the top X% (defined by the threshold) of the screen.
					// Snap the container to the fullyDisplayed position.
					newSnapConstant = _fullyDisplayedConfiguration.constraintConstant
					state = .fullyDisplayed
				} else {
					// We lifted the finger while the container was panned in the bottom 100-X% (defined by the threshold) of the screen.
					// Snap the container to the same position from which we started.
					newSnapConstant = _partiallyDisplayedConfiguration.constraintConstant
				}

			case .fullyDisplayed:
				if _topContainerConstraint.constant >= _fullyDisplayedConfiguration.constraintConstant + _fullyDisplayedConfiguration.threshold {
					// We lifted the finger while the container was panned in the bottom 100-X% (defined by the threshold) of the screen.
					// Snap the container to the same position from which we started.
					newSnapConstant = _partiallyDisplayedConfiguration.constraintConstant
					state = .partiallyDisplayed
				} else {
					// We lifted the finger while the container was panned in the top X% (defined by the threshold) of the screen.
					// Snap the container to the fullyDisplayed position.
					newSnapConstant = _fullyDisplayedConfiguration.constraintConstant
				}

			case .hidden:
				// Do not handle this case in this situation.
				return
			}

			// Update the parameters with the new values.
			_parameters = .init( snapConstant: newSnapConstant, flingVelocity: velocity )

			return
		}

		switch state {
		case .partiallyDisplayed:
			// Velocity != 0 => We flinged.
			if velocity.y > 0.0 {
				// We flinged upwards.
				newSnapConstant = _fullyDisplayedConfiguration.constraintConstant
				state = .fullyDisplayed
			} else {
				// We flinged downwards, reset the _snapConstant if it was reset by mistake.
				newSnapConstant = _partiallyDisplayedConfiguration.constraintConstant
			}

		case .fullyDisplayed:
			// Velocity != 0 => We flinged.
			if velocity.y < 0.0 {
				// We flinged downwards.
				newSnapConstant = _partiallyDisplayedConfiguration.constraintConstant
				state = .partiallyDisplayed
			} else {
				// We flinged upwards, reset the _snapConstant if it was reset by mistake.
				newSnapConstant = _fullyDisplayedConfiguration.constraintConstant
			}

		case .hidden:
			// Do not handle this case in this situation.
			return
		}

		// Update the parameters with the new values.
		_parameters = .init( snapConstant: newSnapConstant, flingVelocity: velocity )
	}

	/**
	Updates the `_topContainerConstraint` and also informs the delegate of the change.
	Should be used instead of manually modifying the `.constant` property outside.

	- parameter constant:		The new constraint value.
	*/
	private func updateConstraint( to constant: CGFloat ) {
		// Assign the new constraint.
		_topContainerConstraint.constant = constant

		// Notify the delegate so he can perform changes as well.
		let positioning: SheetPositioning = .init( constant: constant, collapsedConstant: _partiallyDisplayedConfiguration.constraintConstant, expandedConstant: _fullyDisplayedConfiguration.constraintConstant )
		delegate?.sheetPositionWillChange( positioning: positioning )
	}

	/**
	Creates the snapping animation based on _flingVelocity`, `_snapConstant` and `_topContainerConstraint` values.

	- parameter completion:			Called after the snapping hs finished.
	*/
	open func animateSnapping( animationDuration: TimeInterval = Theme.Durations.standardAnimationDuration, completion: (() -> Void)? = nil ) {
		// Compute the distance we're about to animate.
		let distanceDifference = abs( _parameters.snapConstant - _topContainerConstraint.constant )
		let initialSpringVelocity = distanceDifference != 0.0 ? _parameters.flingVelocity.y / distanceDifference : 1.0

		if !_panningInProgress {
			// Set the flag so we prevent any external changes to the container constraint.
			_panningInProgress = true
		}

		// Assign the new constant
		updateConstraint( to: self._parameters.snapConstant )

		// Animate the constraint of the container.
		UIView.animate( withDuration: animationDuration,
					   delay: 0.0, 											// No delay.
					   usingSpringWithDamping: springDamping, 				// Allow a bit of sprint animation just for niceness.
					   initialSpringVelocity: initialSpringVelocity, 		// Create the velocity based on the velocity with which the drag was about to end.
					   options: [.beginFromCurrentState, .curveLinear], 	// Animate from the current state and use a linear curve for the animation.
					   animations: {
				// Call layoutIfNeeded so the animation is performed smoothly.
				self._view.layoutIfNeeded()
		}, completion: { _ in
			// Reset the flag once we've finished the animation.
			self._panningInProgress = false
			
			// Notify delegate that shit position has been changed.
			self.delegate?.sheetPositionDidChange()

			// Call the completion.
			completion?()
		})
	}

	// MARK: - Pan gesture logic.

	@objc private func panActionHandler( _ panGestureRecognizer: UIPanGestureRecognizer ) {
		// Make sure we have a panGestureView so we can compute translation and velocity.
		guard let panningView = _panningView else {
				// If we're trying to pan the container view while the content offset is not at the starting offset
				// do not react to the panning gesture.
				return
		}

		switch panGestureRecognizer.state {
		case .changed:
			// Pan using the recorded translation inside the view.
			pan( panGestureRecognizer.translation( in: panningView ).y )

			// Reset the translation so we don't get the sum of all translations.
			panGestureRecognizer.setTranslation( .zero, in: panningView )

		case .ended:
			let velocity = panGestureRecognizer.velocity( in: panningView )

			// The velocity we get outside of the container is the opposite coordinate system than the scrollView's velocity.
			// So we have to reverse them by multiplying with -1.
			// We also divide by 1000 to get the velocity in pts/ milliseconds since this one is provided in pts/ seconds.
			// We don't know for sure how the velocity from `func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)`
			// is computed but if we divide by 1000 the values are pretty close.
			let scale: CGFloat = -1 / 1000
			let scaledVelocity = velocity.applying( .init(scaleX: scale, y: scale ) )

			// Since the magnitude of velocity is so big, we almost never get the velocity as `.zero`.
			// We treat the zero velocity case as if the user has lifted the finder without any fling.
			// So, if the user is in the upper part of the screen, but he lifts his finder and the velocity
			// is returned negative, we would snap downwards instead of upwards
			// So, every velocity that is under the threhold will be considered 0.0, just for consistency.
			let clampedX = abs(scaledVelocity.x) < Constants.velocityThreshold ? 0.0 : scaledVelocity.x
			let clampedY = abs(scaledVelocity.y) < Constants.velocityThreshold ? 0.0 : scaledVelocity.y
			let clampedVelocity = CGPoint( x: clampedX, y: clampedY )

			// Keep the value of the state before update so we can compare it to determine wether we need to request
			// the content inside the container view to get scrolled to the top or not.
			let oldState = state

			// Update the new state and snapping points.
			// Use the `updateSnapParameters` since there are no constraints special cases to handle
			// since we're only interracting with the pan and not the scrollView contentOffset.
			updateSnapParameters( clampedVelocity )

			if oldState != state {
				// If we changed the state to make the container partially visible, we should also scroll to the top
				delegate?.shouldScrollContentToTop()
			}

			// Perform the animation here, manually, as there is no other event to trigger it.
			animateSnapping()

		default: break
		}
	}
} 
