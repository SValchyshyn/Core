//
//  UIViewController-Containment.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 21/12/2018.
//  Copyright © 2018 Greener Pastures. All rights reserved.
//

import UIKit

public extension UIViewController {
	/**
	Adds a viewController's view as a subview to the current viewController's view and creates a child-parent relationship.

	- parameter viewController:					The viewController to add as child.
	*/
	func add(viewController: UIViewController) {
		// Create the child-parent relationship between the viewControllers.
		addChild(viewController)

		// Make sure it has the parent's frame otherwise it won't resize automatically for smaller screens
		viewController.view.frame = view.frame

		// Add it's view as a subview.
		view.addSubview(viewController.view)

		// Notify the viewController that is has been moved to the parent viewController's view.
		viewController.didMove(toParent: self)
	}

	/**
	Removes a viewController's view from the superview in which is added. Removed the child-parent relationship.

	- parameter viewController:					The viewController to be removed.
	*/
	func remove(viewController: UIViewController) {
		// Notify the viewController that is going to be removed from the parent viewController.
		viewController.willMove(toParent: nil)
		// Remove the view from the parent's view.
		viewController.view.removeFromSuperview()
		// Remove the child-parent relationship between the viewControllers.
		viewController.removeFromParent()
	}
}
