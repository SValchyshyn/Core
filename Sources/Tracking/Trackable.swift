//
//  Trackable.swift
//  Tracking
//
//  Created by Coruț Fabrizio on 18/03/2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol Trackable {
	/// Screen identifier used for tracking. Should be in `snake_case` format.
	var trackingPageId: String { get }
	
	/// Screen name used for tracking. No format restrictions.
	var trackingPageName: String { get }
}

extension Trackable where Self: UIViewController {
	private func pageNamePath() -> String {
		var path: [String] = []
		var trackableViewController: Trackable? = self
		while trackableViewController != nil {
			path.append( trackableViewController!.trackingPageId )        // We have checked for != nil
			
			// Get parent or presenting view controller
			if let viewController = trackableViewController as? UIViewController {
				if let parent = (viewController as? ParentViewControllerTrackable)?.trackableParentViewController {
					trackableViewController = parent
				} else if let parent = viewController.previousViewControllerOnNavigationStack() as? Trackable {
					trackableViewController = parent
				} else if let parent = viewController.parent as? Trackable {
					trackableViewController = parent
				} else if let parent = viewController.presentingViewController as? Trackable {
					trackableViewController = parent
				} else if let parent = (viewController.presentingViewController as? UINavigationController)?.topViewController as? Trackable {
					trackableViewController = parent
				} else if let parent = ((viewController.presentingViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.topViewController as? Trackable {
					trackableViewController = parent
				} else if let parent = (viewController.previousViewController() as? CurrentViewControllerProvider)?.currentViewController as? Trackable {
					trackableViewController = parent
				} else {
					// No more UIViewController: Trackable in the hierarchy, so add root name and stop loop
					path.append(Tracking.shared.appName)
					trackableViewController = nil
				}
			}
		}
		// print( "\n*** path: \(path.reversed().joined( separator: "/" ))\n"  )
		return path.reversed().joined( separator: "/" )
	}
	
	/**
	Track a page view for this view controller.
	
	All the properties from the `Trackable` protocol will be added if they are present.
	The page title is taken from `Trackable.trackingPageTitle` if non-nil, then `UIViewController.title` is used if non-nil and finally `Trackable.trackingPageName`.
	
	- parameter parameters: Any other parameters to include in tracking
	- parameter includeExtraInfo: Whether the current user's info should be included
	*/
	public func trackViewController( parameters: [String: String]?, includeExtraInfo: Bool = true ) {
		// Add page name path
		var dataSources: [String: String] = [
			Tracking.PageInfoKeys.pageId: self.trackingPageId
		]
		
		// Copy other parameters if present
		if let parameters = parameters {
			for (key, value) in parameters {
				dataSources[ key ] = value
			}
		}
		
		Tracking.shared.trackViewController(self, parameters: dataSources, includeExtraInfo: includeExtraInfo)
	}
	
	/// Track a page view for this view controller.
	/// - Parameters:
	///   - parameters: Any other parameters to include in tracking
	///   - includeExtraInfo: Whether the current user's info should be included
	public func trackViewController(parameters: [Tracking.Parameter] = [], includeExtraInfo: Bool = true) {
		var parameters = parameters
		parameters.append(.init(key: Tracking.PageInfoKeys.pageId, value: trackingPageId))
		Tracking.shared.trackViewController(self, parameters: parameters, includeExtraInfo: includeExtraInfo)
	}
	
}

/**
Helper protocol used to explicitly set the parent viewcontroller for those cases where the view controller hierarchy can't be automatically determined.
*/
public protocol ParentViewControllerTrackable: AnyObject {
	/// Explicitly defined trackable parent view controller
	var trackableParentViewController: Trackable? { get set }
}

/**
Protocol used for decoupling the OffersPagedTabsViewController from the tracking
*/
public protocol CurrentViewControllerProvider {
	var currentViewController: UIViewController { get }
}

extension UIViewController {
	/**
	Get the view controller below self on the navigation stack.
	
	- returns: The view controller below self on the navigation stack, or nil if self is at the bottom or self is not on a navigation stack
	*/
	func previousViewControllerOnNavigationStack() -> UIViewController? {
		if let stack = self.navigationController?.viewControllers {
			for i in (1..<stack.count).reversed() where stack[ i ] == self {
				return stack[ i - 1 ]
			}
		}
		return nil
	}
}
