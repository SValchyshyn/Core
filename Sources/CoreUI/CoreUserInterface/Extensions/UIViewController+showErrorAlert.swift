//
//  UIViewController+showErrorAlert.swift
//  POSCheckin
//
//  Created by Nazariy Vlizlo on 15.10.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit

public extension UIViewController {
	func showErrorAlert(title: String, message: String, okActionHandler: ((_ alertController: BasicAlertViewController) -> Void)? = nil) {
		let topAction = CustomAlertAction.okAction(handler: okActionHandler)
		let alert = BasicAlertViewController(title: title,
											   message: message,
											   topAction: topAction,
											   bottomAction: nil,
											   presentationStyle: .fullWidth)
		present(alert, animated: true)
	}
}
