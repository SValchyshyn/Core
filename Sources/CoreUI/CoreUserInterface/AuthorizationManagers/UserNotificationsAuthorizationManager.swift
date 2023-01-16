//
//  UserNotificationsAuthorizationManager.swift
//  CoreUserInterface
//
//  Created by Georgi Damyanov on 11/12/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit
import UserNotifications
import UserDefault
import Core

/// Enum used to define additional precondition events that are required to happen before prompting for notification permission
public enum NotificationsAuthPreconditionEvent {
	case gamePlayed
}

/// Protocol that defines the interface requirements for `NotificationsAuthorizationManager`
public protocol NotificationsAuthorizationManagerProtocol {
	/// If all conditions are met, shows the notifications pre-permission dialog or requests authorization immediately
	/// by displaying the system dialog if the pre-permission dialog was already shown for a maximum amount of times.
	/// - Parameter viewController: The view controller on which the dialog will be presented.
	func requestAuthorizationIfNeeded(on viewController: UIViewController)

	/// Tags the specific precondition event to mark it as happened. Used to add additional condition requirement before prompting
	/// for authorization, when using the `requestAuthorizationIfNeeded( on: preconditionEvent: )` method.
	/// - Parameter event: One of the `NotificationsAuthPreconditionEvent` enum cases that corresponds to an event that has happened.
	func tag(event: NotificationsAuthPreconditionEvent)

	/// Used to check if additional precondition event has happened, before calling the actual `requestAuthorizationIfNeeded` method.
	/// - Parameter viewController: The view controller on which the dialog will be presented.
	/// - Parameter preconditionEvent: The precondition event, that is required to happen before prompting the user.
	func requestAuthorizationIfNeeded(on viewController: UIViewController, preconditionEvent: NotificationsAuthPreconditionEvent)
}

/// Protocol that defines the interface requirements for `Configuration` used for `UserNotificationsAuthorizationManager`
public protocol NotificationsTrackingConfigurable {

	/// Analytics tracking handler
	var trackingHandler: AuthorizationPermissionAnalyticsTrackable? { get }
}

/**
Manager class for requesting notification permissions. The authoriziation dialog is added to the queue of alerts
*/
public class UserNotificationsAuthorizationManager: NotificationsAuthorizationManagerProtocol {

	private enum Constants {
		static let numberOfTimesPromptedKey = "numberOfTimesPromptedKey"
		static let headerImageName = "notifications_prepermission_alert_img"
	}

	// MARK: - Properties

	/// A number of times the user was prompted for notification permission
	@UserDefault( key: Constants.numberOfTimesPromptedKey, defaultValue: 0 )
	private var numberOfTimesPrompted: Int

	/// Used for providing the custom configuration
	private let trackingConfiguration: NotificationsTrackingConfigurable
	
	/// Provides data about any pre-permission actions that need to be taken.
	private let prePermissionConfiguration: AuthorizationPrepermissionConfigurable?
	
	/// Default notification authorization options
	private var authorizationOptions: UNAuthorizationOptions {
		[.alert, .sound]
	}

	/// Precondition events that were tagged
	private var taggedEvents = Set<NotificationsAuthPreconditionEvent>()

	// MARK: - Public methods

	public init( trackingConfiguration: NotificationsTrackingConfigurable, prePermissionConfiguration: AuthorizationPrepermissionConfigurable? ) {
		self.trackingConfiguration = trackingConfiguration
		self.prePermissionConfiguration = prePermissionConfiguration
	}

	// MARK: - NotificationsAuthorizationManagerProtocol implementation

	public func requestAuthorizationIfNeeded( on viewController: UIViewController ) {
		// Check if manager is configured to show the pre-permission dialog
		guard let dialog = prePermissionConfiguration?.prePermissionDialog else {
			// Skip the pre-permission logic and try showing the system dialog
			return showSystemPermissionDialogIfNeeded()
		}
		
		// Get the notification settings in order to check if we already have authorization
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			// Only request authorization if we have not done that already
			guard settings.authorizationStatus == .notDetermined  else {
				return
			}

			// We have not presented the authorization dialog yet, add it to the queue
			DispatchQueue.main.async {
				// Show the pre-permission dialog
				self.showPrePermissionDialog( dialog, on: viewController ) {
					// Track pre-permission button action
					self.trackingConfiguration.trackingHandler?.trackPrepermissionDialogContinueAction()

					// User agreed to give the permission, show the system dialog
					self.enqueueSystemPermissionDialog()
				}
			}
		}
	}

	// MARK: - Precondition events handling

	public func tag( event: NotificationsAuthPreconditionEvent ) {
		taggedEvents.insert( event )
	}

	public func requestAuthorizationIfNeeded( on viewController: UIViewController, preconditionEvent: NotificationsAuthPreconditionEvent ) {
		// Check if the precondition event has happened, otherwise skip prompting
		guard taggedEvents.contains( preconditionEvent ) else { return }

		// Try to prompt since the precondition event has happened
		requestAuthorizationIfNeeded( on: viewController )

		// Reset the precondition event
		taggedEvents.remove( preconditionEvent )
	}

	// MARK: - Private methods

	/// Shows the system dialog for requesting authorization permission for notifications in case the user has not been prompted before
	private func showSystemPermissionDialogIfNeeded() {
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			// Only request authorization if we have not done that already
			guard settings.authorizationStatus == .notDetermined else {
				return
			}

			// We have not presented the authorization dialog yet, add it to the queue
			DispatchQueue.main.async {
				self.enqueueSystemPermissionDialog()
			}
		}
	}

	/// Inserts the system notifications authorization dialog in front of `AlertCoordinator's` queue to be displayed as next
	private func enqueueSystemPermissionDialog() {
		let authorizationDialog = UserNotificationsAuthorizationDialog( options: authorizationOptions ) { isAccepted in
			// Track system dialog button action
			self.trackingConfiguration.trackingHandler?.trackSystemDialogAction(isAccepted: isAccepted)
		}

		AlertCoordinator.shared.enqueue( authorizationDialog, asNext: true )
	}

	/// Shows the pre-permission dialog for notifications authorization
	/// - Parameter viewController: The view controller on which the dialog will be presented.
	/// - Parameter completion: The completion callback, which has a `Bool` value as a parameter, indicating whether the system authorization dialog can be shown.
	private func showPrePermissionDialog(_ dialog: AuthorizationPrepermissionConfigurable.PrePermissionDialog, on viewController: UIViewController, completion: @escaping () -> Void ) {
		let continueButton = BasicAlertViewController.Button( title: .custom( title: dialog.buttonTitle ),
														   dismissAlert: false ) { alert in
			// User agreed to give the permission, show the system dialog
			completion()

			// It's required to call the `completion` before the alert is dismissed, to be able to schedule
			// the system dialog as next in the AlertCoordinator, before any other scheduled alert is shown
			alert.dismiss(animated: true)
		}

		let image = UIImage( named: Constants.headerImageName, in: Bundle( for: Self.self ), compatibleWith: nil )!

		let imageAlertConfiguration = ImageAlertViewController.Configuration( imageStyle: .big, image: image, presentationStyle: .fullWidth, contentPlacement: .top )
			.byAdding( topButton: continueButton )

		let info = CoreBaseError( title: dialog.title,
								  body: dialog.body )

		let imageViewAlert: ImageAlertViewController = .init( info: info, configuration: imageAlertConfiguration )

		viewController.present( imageViewAlert, animated: true) {
			// Track pre-permission screen view
			self.trackingConfiguration.trackingHandler?.trackPrepermissionDialogView(displayCount: self.numberOfTimesPrompted + 1)
		}
	}
}
