//
//  UIViewController-Extensions.swift
//  Tracking
//
//  Created by Georgi Damyanov on 19/11/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

extension UIViewController {
	/**
	The previously visible view controller, excluding tab bar and navigation controllers. Use this instead of `presentingViewController` when the view controller is presented directly from the tab bar.
	*/
	func previousViewController() -> UIViewController? {
		var previousViewController = presentingViewController

		// Is the presenting view controller a tab bar controller?
		if let tabBarController = previousViewController as? UITabBarController {
			// Yes: Get the selected view controller
			previousViewController = tabBarController.selectedViewController
		}

		// Is the previous view controller a navigation controller?
		if let navigationController = previousViewController as? UINavigationController {
			previousViewController = navigationController.topViewController
		}

		return previousViewController
	}
}
