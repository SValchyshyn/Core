//
//  UINavigationController-Navigation.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 21/12/2018.
//  Copyright © 2018 Greener Pastures. All rights reserved.
//

import UIKit

public extension UINavigationController {
	/**
	Pop the top view controller with completion handler.

	- parameter completion:						Gets called when the pop transaction is finished.
	*/
	func pop(with completion: @escaping () -> Void) {
		// Setup the transaction.
		CATransaction.begin()
		CATransaction.setCompletionBlock(completion)

		// Pop it.
		popViewController(animated: true)

		// Commit the changes.
		CATransaction.commit()
	}

	/**
	Searches for a UIViewController with the specified type in the view heirarchy and pops to it.
	Otherwise pops just the current UIViewController.

	- parameter viewControllerType:				The .Type of the UIViewController.
	*/
	func popTo<T>(_ viewControllerType: T.Type) where T: UIViewController {
		guard let typeViewController = viewControllers.first(where: { $0 is T }) else {
			popViewController(animated: true)
			return
		}

		popToViewController(typeViewController, animated: true)
	}

	/**
	Searches for a UIViewController with the specified type in the view heirarchy and pops to it.
	Otherwise pops just the current UIViewController.

	- parameter viewControllerType:				The .Type of the UIViewController.
	- parameter completion:						Gets called when the pop transaction is finished.
	*/
	func popTo<T>(_ viewControllerType: T.Type, completion: @escaping () -> Void)  where T: UIViewController {
		// Setup the transaction.
		CATransaction.begin()
		CATransaction.setCompletionBlock(completion)

		// Do we have the searched type?
		guard let typeViewController = viewControllers.first(where: { $0 is T }) else {
			// NO: just pop the current viewController.
			popViewController(animated: true)

			// Commit the changes.
			CATransaction.commit()
			return
		}

		// YES: Pop all the other viewControllers up to it.
		popToViewController(typeViewController, animated: true)

		// Commit the changes.
		CATransaction.commit()
	}
}
