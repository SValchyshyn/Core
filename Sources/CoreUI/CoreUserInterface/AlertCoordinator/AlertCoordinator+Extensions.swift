//
//  AlerCoordinator+Extensions.swift
//  CoreUserInterface
//
//  Created by Georgi Damyanov on 08/02/2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import UIKit

/**
Utility functions for presenting a view controller from the alert coordinator
*/
extension AlertCoordinator {
	/**
	Present the given view controller on top of the top-most view controller. We will get the top view controller just before attempting to present.
	*/
	func presentOnTop(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
		enqueue(viewController, animated: animated, completion: completion) {
			UIViewController.topViewController()
		}
	}

	/**
	Present the given view controller on top of the given `presenter` view controller.
	*/
	func present(_ viewController: UIViewController, on presenter: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
		enqueue(viewController, animated: animated, completion: completion) { [weak presenter] in
			// Present only if the presenter is still available and it has not presented any other view controller
			if let presenter = presenter, presenter.presentedViewController == nil {
				return presenter
			} else {
				return nil
			}
		}
	}

	/**
	Utility function for enqueueing the given view controller
	*/
	private func enqueue(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?, presenter: @escaping () -> UIViewController?) {
		let container = ViewControllerAlertContainer(
			viewController: viewController,
			presenter: presenter,
			animated: animated,
			presentCompletion: completion)
		enqueue( container )
	}
}
