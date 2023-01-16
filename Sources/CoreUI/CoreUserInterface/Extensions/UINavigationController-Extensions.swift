//
//  UINavigationController-Extensions.swift
//  CoopCore
//
//  Created by Valeriy Kolodiy on 30.03.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit

public extension UINavigationController {

	/// Pushes a view controller onto the navigation stack and triggers the callback after the push transition finishes.
	/// - Parameters:
	///   - viewController: The view controller to push onto the stack.
	///   - animated: Indicates whether the view controller is pushed animated.
	///   - completion: The block to execute after the push transition finishes.
	func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
		CATransaction.begin()
		CATransaction.setCompletionBlock {
			guard let completion else { return }
			
			guard let coordinator = viewController.transitionCoordinator else {
				return completion()
			}
			
			// Wait `transitionCoordinator` animation completion
			coordinator.animate(alongsideTransition: nil) { _ in
				completion()
			}
		}
		pushViewController(viewController, animated: animated)
		CATransaction.commit()
	}

}
