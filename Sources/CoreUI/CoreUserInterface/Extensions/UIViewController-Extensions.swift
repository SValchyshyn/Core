//
//  UIViewController-Extensions.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 10/09/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

// This is an empty subclass of UIViewController simply to check if we're showing a "wrapped in container view controller" instance
open class MainViewController: UIViewController {}

public extension UIViewController {
	/**
	Extension. Is true when this view controller is embedded as a child inside another view controller (excluding UINavigationController).
	*/
	var isEmbedded: Bool {
		// Check if this view controller is embedded in a parent.
		if let container = parent, !(container is UINavigationController) {
			return true
		}
		
		return false
	}
	
	/**
	Extension. Is true if this view controller is presented as a modal - either directly or inside a UINavigationController or UITabBarController that is presented as a modal.
	*/
	var isModal: Bool {
		// Check if this view controller is simply presented as modal over another.
		if presentingViewController != nil {
			return true
		}
		
		// Check if this view controller is in a navigation controller that is presented as a modal.
		if navigationController?.presentingViewController != nil {
			return true
		}
		
		// Check if this view controller is in a tab bar controller that is presented as a modal.
		if tabBarController?.presentingViewController != nil {
			return true
		}
		
		return false
	}
	
	/**
	Extension. Is true when this view controller is contained by a UINavigationController.
	*/
	var isStacked: Bool {
		return navigationController?.viewControllers.contains( self ) ?? false
	}
	
	/**
	Extension. Is true when this view controller is the root view controller of a UINavigationController.
	*/
	var isStackRoot: Bool {
		return navigationController?.viewControllers.first == self
	}
	
	/**
	Get the front page view controller from the current navigation hierarchy.

	- returns: The front page view controller or nil if none are found.
	*/
	func mainViewController() -> MainViewController? {
		guard let tabBarController = mainTabBarController() else {
			NSLog( "Invalid view hierarchy while trying to access the front page view controller" )
			return nil
		}

		// Assume that the fist view controller of mainTabBarController is always front page
		if let frontPageNavigationController = tabBarController.viewControllers?[ 0 ] as? UINavigationController {
			return frontPageNavigationController.viewControllers[ 0 ] as? MainViewController	// This requires the front page to be the bottom-most view controller in the navigation stack.
		}

		return nil
	}

	/**
	Get the apps main tabbar view controller.
	*/
	func mainTabBarController() -> UITabBarController? {
		let root = UIApplication.currentKeyWindow?.rootViewController
		return root as? UITabBarController
	}
	
	/**
	Present the given view controller using `.fullscreen` modal presentation style, instead of the default `.automatic`
	*/
	func presentInFullScreen(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil ) {
	  viewController.modalPresentationStyle = .fullScreen
	  present( viewController, animated: animated, completion: completion )
	}

	// MARK: - LoadingSpinner methods

	/**
	Shows the loading spinner. Uses `UIView.showLoadingSpinner` implementation.

	- parameter animated:		Whether the appearance should be animated.
	- parameter isModal:		(Optional) if true, all user interaction is blocked until the loading spinner is removed again. Defaults to `false`.
	- parameter color:			Spinner main color, leave blank for default.

	!WARNING!
	If `isModal: true` only the `.view` on which this method is called will be blocked. If the intention is to block the whole screen
	please make sure to call this from the appropriate `.view`. e.g. `tabBarController.view`/ `navigationController.view`.
	*/
	func showLoadingSpinner( animated: Bool, isModal: Bool = false, color: UIColor? = nil ) {
		view.showLoadingSpinner( animated: animated, isModal: isModal, color: color)
	}

	/**
	Hides the loading spinner. Uses UIView showLoadingSpinner implementation.

	- Parameter animated: Whether the hiding should be animated.
	- Parameter removeFromSuperview: Whether the spinner should be removed from its superview. Defaults to `true`.
	*/
	func hideLoadingSpinner( animated: Bool, andRemoveFromSuperview removeFromSuperview: Bool = true ) {
		view.hideLoadingSpinner( animated: animated, andRemoveFromSuperview: removeFromSuperview )
	}
	
	/**
	Convenience method for removing a view controller from the hierarchy. This method will succeed in doing so, if the viewController is inside a UINavigationController stack or if the viewController was presented modally.

	This method tries to use the `popViewController(animated:)`, and if that returns nil, it calls `dismiss(animated:completion:)`.

	*/
	func popOrDismiss( animated: Bool = true ) {
		// `popViewController` returns the popped ViewController. If it returns something, then the current View Controller was popped. Else, we need to dismiss it.
		if navigationController?.popViewController( animated: animated ) == nil {
			dismiss( animated: animated )
		}
	}

	/**
	Dismisses the presented view controller.
	A snapshot view is used to keep the visual appearance of the final, top-most view controller being dismissed instead of the immediately presented one.

	- parameter animated: Animated or not
	- parameter completion: Completion block after dismissal completes.
	*/
	func dismissAllPresentedViewControllers( animated: Bool, completion: (() -> Void)? = nil ) {
		if presentedViewController != nil {
			// Take a snapshot of the current view controller, insert it into the presented view controller's view hierarchy and then dismiss.
			// This is done to prevent the visual appearance of the "no. 2 view controller" being dismissed.
			// See http://stackoverflow.com/a/37602185/1632704
			if let snapshot = UIApplication.shared.delegate?.window??.snapshotView( afterScreenUpdates: false ) {
				presentedViewController?.view.addSubview( snapshot )
			}

			// Dispatch to main thread
			self.dismiss( animated: animated, completion: completion )
		} else {
			// Nothing to dismiss, call the completion handler
			completion?()
		}
	}

	/**
	Get top view controller. NOTE: The check must be done on main thread to avoid runtime warnings.

	- parameter root:	Root view controller at the beginning of the view hierarchy
	- parameter skipAlertViewControllers:	If true, **custom** alert view controllers will be skipped and the view controller _behind_ will be returned. Defaults to `false`.
	- returns:		The top view controller in view hierarchy beginning at root
	*/
	class func topViewController( root: UIViewController? = UIApplication.currentKeyWindow?.rootViewController, skipAlertViewControllers: Bool = false ) -> UIViewController? {
		if let nav = root as? UINavigationController {
			return topViewController( root: nav.visibleViewController, skipAlertViewControllers: skipAlertViewControllers )
		}

		if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
			return topViewController( root: selected, skipAlertViewControllers: skipAlertViewControllers )
		}

		if let presented = root?.presentedViewController {
			// We have a presented view controller. If skipAlertViewControllers is set to true and the presented view controller is a BasicAlertViewController stop recursion here and return root
			if skipAlertViewControllers && presented is BasicAlertViewController {
				return root
			}

			// Otherwise, continue recursion
			return topViewController( root: presented, skipAlertViewControllers: skipAlertViewControllers )
		}

		return root
	}
	
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

	/**
	Adds a `viewController` as a child and presents it's contents in the `containerView`.

	- parameter viewController:		The viewController to embed.
	- parameter containerView:		The `UIView` in which the `viewController's` view will be presented.
	*/
	func addChild( _ viewController: UIViewController, to containerView: UIView ) {
		// Add Child View Controller
		addChild( viewController )

		// Add Child View as Subview
		containerView.addSubview( viewController.view )

		// Pin the edges so we use AutoLayout to resize the child.
		viewController.view.pinEdges( to: containerView )

		// Notify Child View Controller
		viewController.didMove( toParent: self )
	}
}

public extension Array where Element == UIViewController {
	/// Returns first index of UIViewController subclass from the array of UIViewControllers.
	/// - Parameter class: `AnyClass` object representing `UIViewController` class.
	/// - Returns: `Int?` index.
	func firstIndexOfViewControllerClass( ofClass `class`: AnyClass ) -> Int? {
		return firstIndex( where: { $0.isKind( of: `class` ) })
	}
}
