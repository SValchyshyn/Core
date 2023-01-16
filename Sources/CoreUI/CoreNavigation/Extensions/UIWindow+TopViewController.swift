//
//  UIWindow+TopViewController.swift
//  CoreUserInterface
//
//  Created by Nazariy Vlizlo on 17.08.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

public extension UIWindow {
	func topViewController() -> UIViewController? {
		var top = self.rootViewController
		while true {
			if let presented = top?.presentedViewController {
				top = presented
			} else if let nav = top as? UINavigationController {
				top = nav.visibleViewController
			} else if let tab = top as? UITabBarController {
				top = tab.selectedViewController
			} else {
				break
			}
		}
		return top
	}
}
