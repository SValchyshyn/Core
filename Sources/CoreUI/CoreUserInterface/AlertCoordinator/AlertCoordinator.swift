//
//  AlertCoordinator.swift
//  CoreUserInterface
//
//  Created by Georgi Damyanov on 09/12/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit
import Core
import Log

public protocol AlertRepresenting {
	/// Present the alert over the given view controller. The completion should be called once the alert has been dismissed.
	func present( overViewController: UIViewController, didDismiss: @escaping () -> Void )

	/// Used for ensuring that the same dialog is not queued twice.
	func isEqualTo(_ otherAlert: AlertRepresenting) -> Bool

	/// The view controller responsible for presenting the alert.
	var presenter: () -> UIViewController? { get }
}

/**
Default implementation of `isEqualTo` for objects that are already `Equatable`
*/
public extension AlertRepresenting where Self: Equatable {
	func isEqualTo(_ otherAlert: AlertRepresenting) -> Bool {
		guard let otherAlert = otherAlert as? Self else { return false }
		return self == otherAlert
	}
}

public extension AlertRepresenting {
	/// By default the alert is presented over the top view controller
	var presenter: () -> UIViewController? {
		return { UIViewController.topViewController() }
	}
}

/**
Properties which can be overridden in order to allow any view controller to participate in the queue
*/
extension UIViewController {
	/// Must be overridden by view controller which want to participate in the alert queue
	@objc var presentationAlertCoordinator: AlertCoordinator? { nil }

	/// Should the view controller be presented over the top view controller or over the initial presenting view controller?
	@objc var isContextSpecificPresentation: Bool { false }
}

public class AlertCoordinator: NSObject {
	private struct Constants {
		/// We use this number for debugging purposes. We want to be notified if the queue reaches an unreasonable size.
		static let maxAlertCount = 5
	}

	/// Singleton instance of the alert coordinator
	public static let shared = AlertCoordinator()

	/// A queue for all the alerts and a variable for the current alert and its view controller target
	private var queue: [AlertRepresenting] = []

	/// The alert we currently showing
	public var current: AlertRepresenting?

	/// Is the queue currently showing an alert?
	var isCurrentlyPresenting: Bool {
		if let alert = current as? ViewControllerAlertContainer {
			return alert.isPresented
		} else {
			return current != nil
		}
	}

	private override init() { }

	/**
	Setup the coordinator. This will swizzle the presentation and dismissal of view controllers, so we can detect when an alert is presented and dismissed.. We want to queue it, instead of presenting it directly
	*/
	public func setup() {
		UIViewController.swizzleUIViewControllerPresent()
		UIViewController.swizzleUIViewControllerDismiss()
	}

	/**
	Check if the given alert is already present in the queue
	*/
	private func isQueued(_ alert: AlertRepresenting ) -> Bool {
		var queuedAlerts = queue
		current.map{ queuedAlerts.append( $0 )}	// We also take into consideration the current alert.
		return queuedAlerts.first( where: { $0.isEqualTo( alert ) } ) != nil
	}

	public func enqueue(_ alert: AlertRepresenting, asNext: Bool = false ) {
		// Make sure we're on the main thread, since we access UI elements
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { self.enqueue( alert )}
		}

		// Ensure the alert is not duplicate
		if !isQueued( alert ) {
			if asNext {
				queue.insert( alert, at: 0 )
			} else {
				queue.append( alert )
			}
		} else {
			Log.technical.log(.warning, "Attempting to present duplicate alert: \(String( describing: alert ))", [.identifier("alertCoordinator.duplicateAlert")])
		}

		// Log unusually log queues
		if queue.count > Constants.maxAlertCount {
			Log.technical.log(.warning, "The alert queue has reached a size of \(Constants.maxAlertCount)", [.identifier("alertCoordinator.queueSize")])
		}

		// If we are not presenting anything at the moment show the next alert
		if !isCurrentlyPresenting { showNext() }
	}

	private func show(_ alert: AlertRepresenting) {
		// Make sure we're on the main thread, since we access UI elements
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { self.show( alert )}
		}

		guard let presenter = alert.presenter() else {
			// The presenter is gone
			showNext()
			return
		}

		alert.present( overViewController: presenter, didDismiss: { self.showNext() })
	}

	private func showNext() {
		current = queue.popFirst()
		current.map(show)
	}

}

/**
Small utility for adding a pop functionality to an array
*/
fileprivate extension Array {
	mutating func popFirst() -> Element? {
		if isEmpty { return nil }
		defer { self = Array(dropFirst()) }
		return first
	}
}
