//
//  UIViewController+presentAlert.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 29/07/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit
import Core

public extension UIViewController {
	/**
	Utility function for presenting an alert with (localized) "Error" as the title and the specified message with one "OK" button.
	If an error is also passed, the alert will be shown using seeMoreMessage
	*/
	func presentErrorAlertController( message: String = CoreLocalizedString( "error_generic_action_body" ), error: Error? = nil ) {
		DispatchQueue.main.async {
			let alertController: BasicAlertViewController
			if let error = error {
				alertController = BasicAlertViewController( title: CoreLocalizedString( "error_generic_action_title" ), message: message, topAction: .okAction(), bottomAction: nil, seeMoreMessage: String( describing: error ), presentationStyle: .fullWidth, accessibilityIdentifier: "GenericErrorAlert" )
			} else {
				alertController = BasicAlertViewController( title: CoreLocalizedString( "error_generic_action_title" ), message: message, topAction: .okAction(), bottomAction: nil, presentationStyle: .fullWidth, accessibilityIdentifier: "GenericErrorAlert" )
			}
			self.present( alertController, animated: true )
		}
	}

	/// Utility function for presenting a `server generated error` with an `Ok` button.
	/// - Parameter shouldDismiss: `true` will dismiss the current viewController as well upon pressing the `Ok` button.
	func presentServerErrorAlertController( shouldDismiss: Bool = false ) {
		// Make sure we're on the main thread since we're doing UI changes.
		guard Thread.isMainThread else {
			// We're not. Dispatch to the main thread.
			return DispatchQueue.main.async { self.presentServerErrorAlertController( shouldDismiss: shouldDismiss ) }
		}

		// Configure the button based on whether we should dismiss the curernt viewController as well.
		let topButton: BasicAlertViewController.Button = .ok( action: { _ in
			shouldDismiss ? self.dismiss( animated: true ) : ()
		})
		// Provide any extra information used for configuring the alert.
		let configuration = BasicAlertViewController.Configuration( presentationStyle: .fullWidth, accessibilityIdentifier: "ServerGenericErrorAlert" )
			.byAdding( topButton: topButton )
		// Create the alert from the error and configuration
		let alert: BasicAlertViewController = .init( info: GeneralErrors.server, configuration: configuration )
		// Present it animated.
		present( alert, animated: true )
	}

	/**
	Utility function for presenting an alert with (localized) "Error" as the title and the specified message with one "OK" button that will dismiss `self` upon tap.
	If an error is also passed, the alert will be shown using seeMoreMessage
	*/
	func presentErrorDismissAlertController( message: String = CoreLocalizedString( "error_generic_action_body" ), error: Error? = nil ) {
		DispatchQueue.main.async {
			let alertController: BasicAlertViewController
			let okAction = CustomAlertAction.okAction { _ in self.dismiss( animated: true ) }
			if let error = error {
				alertController = BasicAlertViewController( title: CoreLocalizedString( "error_generic_action_title" ), message: message, topAction: okAction, bottomAction: nil, seeMoreMessage: String( describing: error ), presentationStyle: .fullWidth )
			} else {
				alertController = BasicAlertViewController( title: CoreLocalizedString( "error_generic_action_title" ), message: message, topAction: okAction, bottomAction: nil, presentationStyle: .fullWidth )
			}
			self.present( alertController, animated: true )
		}
	}

	/**
	Utility function for presenting an alert with provided error title and message with one "OK" button.
	*/
	func presentCustomErrorAlertController( title: String, message: String, accessibilityIdentifier: String? = nil, shouldDismiss: Bool = false ) {
		var okAction: CustomAlertAction

		if shouldDismiss {
			okAction = CustomAlertAction.okAction { _ in self.dismiss( animated: true ) }
		} else {
			okAction = .okAction()
		}

		DispatchQueue.main.async {
			let alertController: BasicAlertViewController = .init( title: title, message: message, topAction: okAction, bottomAction: nil, presentationStyle: .fullWidth, accessibilityIdentifier: accessibilityIdentifier )
			self.present( alertController, animated: true )
		}
	}

	/**
	Utility function for presenting an alert with "Network is not reachable" title and message and with one "OK" button.
	*/
	func presentNetworkNotReachableError( shouldDismiss: Bool = false ) {
		DispatchQueue.main.async {
			let title = CoreLocalizedString( "error_network_unavailable_title" )
			let message = CoreLocalizedString( "error_network_unavailable_body" )

			self.presentCustomErrorAlertController( title: title, message: message, accessibilityIdentifier: "NetworkIsNotReachableGenericErrorAlert", shouldDismiss: shouldDismiss )
		}
	}
}
