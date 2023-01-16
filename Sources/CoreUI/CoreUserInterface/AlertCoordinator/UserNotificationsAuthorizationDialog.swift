//
//  UserNotificationsAuthorizationDialog.swift
//  CoreUserInterface
//
//  Created by Georgi Damyanov on 11/12/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UserNotifications
import UIKit

/**
Container for enqueueing a UNUserNotifications authorization dialog via the `AlertCoordinator`
*/
struct UserNotificationsAuthorizationDialog: AlertRepresenting {
	let options: UNAuthorizationOptions
	let completionHandler: (Bool) -> Void

	func present( overViewController: UIViewController, didDismiss: @escaping () -> Void ) {
		UNUserNotificationCenter.current().requestAuthorization( options: options )  { granted, _ in
			DispatchQueue.main.async {
				// Notify the alert coordinator that we are done
				didDismiss()

				if granted {
					// Authorization is granted. Register for notifications.
					UIApplication.shared.registerForRemoteNotifications()
				}

				completionHandler(granted)
			}
		}
	}
}

/**
We implement `Equatable` in order to ensure that the same dialog is not queued twice.
*/
extension UserNotificationsAuthorizationDialog: Equatable {
	public static func == (lhs: UserNotificationsAuthorizationDialog, rhs: UserNotificationsAuthorizationDialog) -> Bool {
		return lhs.options == rhs.options
	}
}
