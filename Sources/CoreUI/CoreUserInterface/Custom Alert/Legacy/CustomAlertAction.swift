//
//  CustomAlertAction.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 30/07/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import Core

public class CustomAlertAction {
	let title: String
	let handler: ((_ alertController: BasicAlertViewController) -> Void)?
	let dismissAlert: Bool

	public init( title: String, dismissAlert: Bool = true, handler: ((_ alertController: BasicAlertViewController) -> Void)?) {
		self.title = title
		self.handler = handler
		self.dismissAlert = dismissAlert
	}

	/**
	Returns a custom alert action with the button text set to (localized) OK and the specified action.

	- parameters:
	- handler: The handler to handle the tap gesture
	- dismissAlert: A flag indicating whether the alert should be dismissed automatically
	*/
	public class func okAction( dismissAlert: Bool = true, handler: ((_ alertController: BasicAlertViewController) -> Void)? = nil ) -> CustomAlertAction {
		return CustomAlertAction( title: CoreLocalizedString( "button_ok" ), dismissAlert: dismissAlert, handler: handler )
	}

	/// Returns a custom alert action with the button text set to (localized) "Cancel" and the specified action.
	///
	/// - Parameters:
	///   - dismissAlert: A flag indicating whether the alert should be dismissed automatically. Defaults to `true`.
	///   - handler: The handler to handle the tap gesture. Defaults to `nil`.
	/// - Returns: A `CustomAlertAction` with a localized "Cancel" button and the specified handler.
	public class func cancelAction( dismissAlert: Bool = true, handler: ((_ alertController: BasicAlertViewController) -> Void)? = nil ) -> CustomAlertAction {
		return CustomAlertAction( title: CoreLocalizedString( "button_cancel_annuller" ), dismissAlert: dismissAlert, handler: handler )
	}

	/// Returns a custom alert action with the button text set to (localized) "Try again" and the specified action.
	///
	/// - Parameters:
	///   - dismissAlert: A flag indicating whether the alert should be dismissed automatically. Defaults to `true`.
	///   - handler: The handler to handle the tap gesture. Defaults to `nil`.
	/// - Returns: A `CustomAlertAction` with a localized "Try again" button and the specified handler.
	public class func retry( dismissAlert: Bool = true, handler: ((_ alertController: BasicAlertViewController) -> Void)? = nil ) -> CustomAlertAction {
		return CustomAlertAction( title: CoreLocalizedString( "button_retry" ), handler: handler )
	}
}
