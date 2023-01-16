//
//  UIViewController+presentSwizzling.swift
//  AlertCoordinator
//
//  Created by Olexandr Belozierov on 03.02.2021.
//

import UIKit

/**
We swizzle the view controller presentation in order to enqueue the view controllers which want to be part of the alert queue.
*/
extension UIViewController {

	/**
	Swap the `present` view controller function with one that will enqueue view controllers that use the AlertCoordinator.
	*/
	static func swizzleUIViewControllerPresent() {
		exchangeSelectors(for: UIViewController.self, originalSelector: #selector(present),
						  swizzledSelector: #selector(swizzled_present))
	}

	/**
	Instead of directly presenting the view controller we first check if it should be part of the AlertCoordinator
	*/
	@objc func swizzled_present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
		guard let coordinator = viewControllerToPresent.presentationAlertCoordinator else {
			// We should not use the alert queue. Use the regular present function.
			return swizzled_present(viewControllerToPresent, animated: animated, completion: completion)
		}

		// Present over the correct view controller, depending if the presentation is context specific.
		viewControllerToPresent.isContextSpecificPresentation
			? coordinator.present(viewControllerToPresent, on: self, animated: animated, completion: completion)
			: coordinator.presentOnTop(viewControllerToPresent, animated: animated, completion: completion)
	}
}
