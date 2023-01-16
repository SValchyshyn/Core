//
//  ViewControllerAlertContainer.swift
//  CoreUserInterface
//
//  Created by Georgi Damyanov on 04/02/2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import UIKit
import Core

/**
Container used when enqueuing view controllers in the alert queue.
*/
struct ViewControllerAlertContainer: AlertRepresenting {
	func present(overViewController: UIViewController, didDismiss: @escaping () -> Void ) {
		// Sanity check, the view controller should not be presented yet.
		assert(!isPresented)

		// Do we have where to present the view controller from?
		guard let presenter = presenter() else {
			// No: Move forward to the next alert in the queue
			didDismiss()
			return
		}

		// Call the `swizzle_present`, this will trigger the original `present` since we dynamically swapped the functions.
		presenter.swizzled_present( viewController, animated: true, completion: presentCompletion )

		// Check if the view controller is being presented. If that's not the cause an error could have occurred.
		if viewController.isBeingPresented {
			// Wait for the view controller to be dismissed
			observeDismiss( completion: didDismiss )
		} else {
			// For some reason the view controller is not being presented. Move to the the next alert in the queue
			didDismiss()
		}
	}

	let viewController: UIViewController
	var presenter: () -> UIViewController?
	let animated: Bool
	let presentCompletion: (() -> Void)?

	/// Is the alert currently visible?
	var isPresented: Bool {
		viewController.viewIfLoaded?.window != nil
			|| viewController.isBeingPresented
			|| viewController.isMovingToParent
			|| viewController.isMovingFromParent
	}

	private func observeDismiss( completion: @escaping () -> Void )  {
		NotificationCenter.default.observeOnce( for: UIViewController.didDismissNotification, object: viewController ) {
			completion()
		}
	}
}

extension ViewControllerAlertContainer: Equatable {
	/**
	Compare the containers according to view controllers they contain.
	*/
	static func == (lhs: ViewControllerAlertContainer, rhs: ViewControllerAlertContainer) -> Bool {
		return lhs.viewController.isEqual( rhs.viewController )
	}
}
