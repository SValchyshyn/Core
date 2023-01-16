//
//  SnackBarPresenter.swift
//  CoreUserInterface
//
//  Created by Olexandr Belozierov on 01.08.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit
import Combine

/// Wrapper for snack bar view that manages show/hide functionality.
open class SnackBarPresenter<SnackBar: UIView> {
	
	public enum Constants {
		public static var defaultShowDuration: TimeInterval { 3 }
	}
	
	public enum Event {
		case willAppear(fromStart: Bool)
		case didAppear(isFinished: Bool)
		case willDisappear(fromEnd: Bool)
		case didDisappear(isFinished: Bool)
	}
	
	private enum State {
		case showAnimation(animator: UIViewPropertyAnimator)
		case shown(autoHideTimer: Timer?)
		case hideAnimation(animator: UIViewPropertyAnimator)
		case hidden
	}
	
	/// Default configuration to show snack bar at the bottom of superview.
	public static func atBottom(of view: UIView, snackBar: SnackBar, showDuration: TimeInterval? = Constants.defaultShowDuration) -> SnackBarPresenter {
		.init(snackBar: snackBar, layout: .atBottom(of: view), animator: .fromBottom, showDuration: showDuration)
	}
	
	/// Snack bar view
	public let snackBar: SnackBar
	
	/// Show duration for snack bar
	public var showDuration: TimeInterval?
	
	/// Layout for snack bar in superview
	private let layout: Layout
	
	/// Show/hide animator provider
	private let animator: Animator
	
	/// Subject to broadcast events
	private let eventBroadcaster = PassthroughSubject<Event, Never>()
	
	/// Snack bar state
	private var state = State.hidden
	
	public init(snackBar: SnackBar, layout: Layout, animator: Animator, showDuration: TimeInterval? = Constants.defaultShowDuration) {
		self.snackBar = snackBar
		self.layout = layout
		self.animator = animator
		self.showDuration = showDuration
	}
	
	/// Flag that determines whether snack bar is not shown
	public var isHidden: Bool {
		switch state {
		case .hidden: return true
		default: return false
		}
	}
	
	/// Publisher for events
	public var events: AnyPublisher<Event, Never> {
		eventBroadcaster.eraseToAnyPublisher()
	}
	
	private func makeAnimator(show: Bool) -> UIViewPropertyAnimator {
		animator.makeAnimator(for: self, show: show)
	}
	
	// MARK: Show
	
	/// Shows snack bar.
	public func show() {
		switch state {
		case .showAnimation:
			break
			
		case .shown(let timer):
			timer?.invalidate()
			state = .shown(autoHideTimer: makeAutoHideTimer())
			
		case .hideAnimation(let animator):
			animator.finishAtCurrentPosition()
			eventBroadcaster.send(.willAppear(fromStart: false))
			perfromShowAnimation()
			
		case .hidden:
			configureSnackBar()
			eventBroadcaster.send(.willAppear(fromStart: true))
			perfromShowAnimation()
		}
	}
	
	private func configureSnackBar() {
		if snackBar.superview == nil {
			layout.configureLayout(for: snackBar)
		}
		
		UIView.performWithoutAnimation {
			snackBar.superview?.layoutIfNeeded()
			makeAnimator(show: false).startAnimation()
		}
	}
	
	private func perfromShowAnimation() {
		let animator = makeAnimator(show: true)
		animator.addCompletion { [self] position in
			switch position {
			case .end:
				state = .shown(autoHideTimer: makeAutoHideTimer())
				eventBroadcaster.send(.didAppear(isFinished: true))
				
			default:
				eventBroadcaster.send(.didAppear(isFinished: false))
			}
		}
		
		animator.startAnimation()
		state = .showAnimation(animator: animator)
	}
	
	private func makeAutoHideTimer() -> Timer? {
		showDuration.map { duration in
			.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in self.hide() }
		}
	}
	
	// MARK: Hide
	
	/// Hides snack bar.
	public func hide() {
		switch state {
		case .showAnimation(let animator):
			animator.finishAtCurrentPosition()
			eventBroadcaster.send(.willDisappear(fromEnd: false))
			performHideAnimation()
			
		case .shown(let timer):
			timer?.invalidate()
			eventBroadcaster.send(.willDisappear(fromEnd: true))
			performHideAnimation()
			
		case .hideAnimation, .hidden:
			break
		}
	}
	
	private func performHideAnimation() {
		let animator = makeAnimator(show: false)
		animator.addCompletion { [self] position in
			switch position {
			case .end:
				snackBar.removeFromSuperview()
				state = .hidden
				eventBroadcaster.send(.didDisappear(isFinished: true))
				
			default:
				eventBroadcaster.send(.didDisappear(isFinished: false))
			}
		}
		
		animator.startAnimation()
		state = .hideAnimation(animator: animator)
	}
	
}

private extension UIViewPropertyAnimator {
	
	func finishAtCurrentPosition() {
		stopAnimation(false)
		finishAnimation(at: .current)
	}
	
}
