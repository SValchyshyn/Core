//
//  BasicAlertViewController+TextConfiguration.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 02.03.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

extension BasicAlertViewController {

	/// Configuration for Alert texts.
	public struct TextConfiguration {
		/// Alert title.
		let title: String

		/// Alert message.
		let message: String

		/// Top action title.
		let topActionTitle: String

		/// Bottom action title.
		let bottomActionTitle: String

		/// Initializer for `TextConfiguration`.
		/// - Parameters:
		///   - title: `String` object. Alert title.
		///   - message: `String` object. Alert message.
		///   - topActionTitle: `String` object. Top action title.
		///   - bottomActionTitle: `String` object. Bottom action title.
		public init( title: String, message: String, topActionTitle: String, bottomActionTitle: String ) {
			self.title = title
			self.message = message
			self.topActionTitle = topActionTitle
			self.bottomActionTitle = bottomActionTitle
		}
	}

	/// Initialize custom alert dialog using a text configuration.
	/// **Important:** Must be called on main thread.
	///
	/// - Parameters:
	///   - configuration: `TextConfiguration` object.
	///   - topAction: Action to be performed by the `topButton`.
	///   - bottomAction: Action to be performed by the `bottomButton`.
	public convenience init( configuration: TextConfiguration, topAction: @escaping () -> Void, bottomAction: @escaping () -> Void ) {
		// Create the actions based on the configuration and blocks.
		let topAction = CustomAlertAction( title: configuration.topActionTitle ) { _ in topAction() }
		let bottomAction = CustomAlertAction( title: configuration.bottomActionTitle ) { _ in bottomAction() }

		// Create the alert based on the configuration and actions.
		self.init( title: configuration.title, message: configuration.message, topAction: topAction, bottomAction: bottomAction )
	}
}
