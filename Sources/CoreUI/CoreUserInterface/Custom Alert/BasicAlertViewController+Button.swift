//
//  AlertAction.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 30/07/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public extension BasicAlertViewController {

	struct Button {
		public typealias Action = ( BasicAlertViewController ) -> Void

		/// Defines the title of the alert button.
		public let title: String

		/// Defines the effects performed by the alert button being tapped.
		public let action: Action?

		/// `true` if the action should automatically dismiss the alert. `false` if we want to leave the dismissal to the `action`.
		public let dismissAlert: Bool

		/// Defines if the button should be round or underlined
		public let buttonStyle: AlertButtonStyle

		// MARK: - Init.

		public init( buttonRepresentable: AlertButtonTitleRepresentable, dismissAlert: Bool, action: Action? = nil ) {
			self.title = buttonRepresentable.title
			self.action = action
			self.dismissAlert = dismissAlert
			self.buttonStyle = buttonRepresentable.buttonStyle
		}

		/**
		- parameter button:	Type-safe way of defining a button `title`.
		- parameter action:	Action to be performed when the button is `tapped`. Default value `nil`.
		*/
		public init( title: BasicAlertViewController.DefaultButtonTitle, dismissAlert: Bool, action: Action? = nil ) {
			self.init( buttonRepresentable: title, dismissAlert: dismissAlert, action: action )
		}

		// MARK: - Convenience init.

		/// Creates a `Button` with the `BasicAlertViewController.DefaultButtonTitle.ok` as `button` parameter.
		public static func ok( dismissAlert: Bool = true, action: Action? = nil ) -> Button {
			return .init( title: .ok, dismissAlert: dismissAlert, action: action )
		}

		/// Creates a `Button` with the `BasicAlertViewController.DefaultButtonTitle.cancel` as `button` parameter.

		public static func cancel( dismissAlert: Bool = true, action: Action? = nil ) -> Button {
			return .init( title: .cancel, dismissAlert: dismissAlert, action: action )
		}

		/// Creates a `Button` with the `BasicAlertViewController.DefaultButtonTitle.retry` as `button` parameter.
		public static func retry( dismissAlert: Bool = true, action: Action? = nil ) -> Button {
			return .init( title: .retry, dismissAlert: dismissAlert, action: action )
		}
	}
}
