//
//  RequestPushNotificationOperation.swift
//  StartupManager
//
//  Created by Jens Willy Johannsen on 26/11/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

import UIKit
import UserNotifications

extension StartupManager {
	/**
	This operation is used to request push notification and user notification settings.
	The current AppDelegate will receive callbacks as usual.

	There is no completion handler – completion/failure must be handled in the AppDelegate callbacks.
	*/
	open class RequestPushNotificationOperation: Operation {
		public struct Keys {
			static let startupManagerPushToken = "_startupManagerPushToken"
		}

		open override var isExecuting: Bool {
			return _executing
		}

		open override var isFinished: Bool {
			return _finished
		}

		open override var isAsynchronous: Bool {
			return true
		}

		// Property backing ivars should be KVO compliant
		fileprivate var _executing: Bool = false {
			willSet {
				willChangeValue(forKey: "isExecuting")
			}
			didSet {
				didChangeValue(forKey: "isExecuting")
			}
		}

		fileprivate var _finished: Bool = false {
			willSet {
				willChangeValue(forKey: "isFinished")
			}
			didSet {
				didChangeValue(forKey: "isFinished")
			}
		}

		fileprivate var _notificationOptions = UNAuthorizationOptions()

		/**
		Designated initializer.
		
		All callbacks are sent to the current AppDelegate and must be handled there. There is no completion handler to this operation as success/failure must be handled in AppDelegate callbacks.
		This operation requires iOS8 or higher.
		
		- parameter types: The UIUserNotificationType types to register for.
		*/
		public convenience init(options: UNAuthorizationOptions) {
			self.init()
			_notificationOptions = options
		}

		open override func start() {
			// Make sure we're not cancelled
			if isCancelled {
				_executing = false
				_finished = true
				return
			}
			_executing = true

			// Get the notification settings in order to check if we already have authorization
			let center = UNUserNotificationCenter.current()
			center.getNotificationSettings { settings in

				// Only request authorization if we have not done that already
				guard settings.authorizationStatus != .authorized && settings.authorizationStatus != .denied else {
					self.done()
					return
				}

				center.requestAuthorization( options: self._notificationOptions )  { granted, _ in
					if granted {
						// Authorization is granted. Register for notifications.
						DispatchQueue.main.async {
							UIApplication.shared.registerForRemoteNotifications()
						}
					}
					self.done()
				}
			}
		}

		public func done() {
			_executing = false
			_finished = true
		}

		// MARK: - Class functions

		/**
		Returns the current push notification token if we have one.
		
		- returns: The last received push notification token or nil if we have never received one.
		*/
		open class func currentPushNotificationToken() -> Data? {
			return UserDefaults.standard.object(forKey: RequestPushNotificationOperation.Keys.startupManagerPushToken) as? Data
		}

		/**
		Returns the current push notification token as a string if we have one.
		
		- returns: The last received push notitfication token string or nil if we have never received one.
		*/
		open class func currentPushNotificationTokenString() -> String? {
			let token = UserDefaults.standard.object(forKey: RequestPushNotificationOperation.Keys.startupManagerPushToken) as? Data

			if let token = token {
				// Convert the token to string by iterating bytes in token data and printing as hex
				let stringToken = token.reduce("", { $0 + String(format: "%02X", $1) })
				return stringToken
			}

			return nil
		}

		/**
		Saves the specified push notification token in user defaults.
		Use this method to save "manually retrieved" tokens so they can be queried using StartupManager.currentPushNotificationToken() and .currentPushNotificationTokenString().
		
		- parameter token: The push token to save.
		*/
		open class func saveCurrentPushNotificationToken(_ token: Data) {
			UserDefaults.standard.set(token, forKey: RequestPushNotificationOperation.Keys.startupManagerPushToken)
			UserDefaults.standard.synchronize()
		}

		// MARK: - AppDelegate method handlers

		/**
		Handle app delegate ApplicationDidBecomeActive event when using RequestPushNotificationOperation.
		This is necessary to get a push token in case the user initially denied permissions.
		*/
		open class func applicationDidBecomeActive() {
			let center = UNUserNotificationCenter.current()

			// Get the notification settings in order to check if we have authorization
			center.getNotificationSettings { settings in

				// Only register if we have authorization
				guard settings.authorizationStatus == .authorized else {
					return
				}

				// We have user permissions but remote notifications may not have been registered yet. Register for push notifications now.
				// NOTE: It is OK to call registerForRemoteNotifications multiple times according to Apple: "If your app previously registered for remote notifications, calling the registerForRemoteNotifications method again does not incur any additional overhead"
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
				}
			}
		}
	}
}
