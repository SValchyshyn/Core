//
//  UIViewController+swizzling.swift
//  AlertCoordinator
//
//  Created by Olexandr Belozierov on 03.02.2021.
//

import UIKit
import Core

/**
We swizzle the view controller `didDisappear` in order to notify any observers when this happens.
*/
extension UIViewController {
	static let didDismissNotification = Notification.Name(#function)

	/**
	Swap the `viewDidDisappear` function so we can detect when a view controller is about to be dismissed.
	*/
	static func swizzleUIViewControllerDismiss() {
		exchangeSelectors( for: UIViewController.self, originalSelector: #selector(viewDidDisappear),
						  swizzledSelector: #selector(swizzled_viewDidDisappear) )
	}
	
	@objc private func swizzled_viewDidDisappear(_ animated: Bool) {
		swizzled_viewDidDisappear(animated)
		if isBeingDismissed { postDidDismiss() }
	}

	/**
	Notify observers that the current view controller is being dismissed.
	*/
	private func postDidDismiss() {
		let name = UIViewController.didDismissNotification
		NotificationCenter.default.post(name: name, object: self)
	}
}
