//
//  BasicAlertViewController+Configuration.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 30/07/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public extension BasicAlertViewController {

	/// Contains all the customization information needed by the `BasicAlertViewController`.
	class Configuration {
		/// Defines how the alert should be positioned on the screen.
		public enum PresentationStyle {
			/// The alert occupues the full witdh of the screen, but we have padding on top and bottom
			case fullWidth

			/// The alert occupies the whole screen
			case fullScreen
		}

		/// Defines the behavior for the `top` button.
		public private(set) var topButton: Button?

		/// Defines the behavior for the `bottom` button.
		public private(set) var bottomButton: Button?

		public private(set) var presentationStyle: PresentationStyle

		/// Configures the alert to be visible for `Accessibility`.
		public let accessibilityIdentifier: String?

		/// Contains extra information used for debugging purposes. Usually contains a `String` representation of the actual `Error` that caused the alert display in the first place.
		public let seeMoreMessage: String?

		// MARK: - Init.

		/// Will default `topButtonAction` and `bottomButtonAction` to `nil`.
		/// - Parameters:
		///   - presentationStyle: Defines how the alert should be positioned on the screen. Default value is `fullWidth`.
		///   - seeMoreMessage: See more message. Only shown in `Debug` configuration. Default value: `nil`.
		///   - accessibilityIdentifier: Identifier used for finding the alert during UI tests. Default value: `nil`.
		public init( presentationStyle: PresentationStyle = .fullWidth, seeMoreMessage: String? = nil, accessibilityIdentifier: String? = nil ) {
			self.topButton = nil
			self.bottomButton = nil
			self.presentationStyle = presentationStyle
			self.seeMoreMessage = seeMoreMessage
			self.accessibilityIdentifier = accessibilityIdentifier
		}

		// MARK: - Building methods.

		/// - Parameter topButton: Custom alert action for the top button. If not specifœied the button is removed.
		/// - Returns: A new `Configuration` containing a `topAction`.
		open func byAdding( topButton: Button ) -> Self {
			self.topButton = topButton
			return self
		}

		/// - Parameter bottomButton: Custom alert action for the bottom button. If not specified the button is removed.
		/// - Returns: A new `Configuration` containing a `topAction`.
		open func byAdding( bottomButton: Button ) -> Self {
			self.bottomButton = bottomButton
			return self
		}
	}
}

// MARK: - Example ~ will be removed once we finalize the iteration over the error building blocks.

///		extension BasicAlertViewController
/// 	{
/// 		convenience init( error: AlertRepresentableError, configuration: Configuration )
/// 		{
/// 			let title = error.title
/// 			let body = error.body
/// 			let topAction = configuration.topButtonAction
/// 			let bottomAction = configuration.bottomButtonAction
/// 			let isFullWidth = configuration.isFullWidth
/// 			let accessibilityIdentifier = configuration.accessibilityIdentifier
/// 		}
///
///			convenience init( info: AlertRepresentableRichInfo, configuration: Configuration )
/// 		{
///				self.init( error: info, configuration: configuration )
///				// do extra attributed string configurations.
/// 		}
/// 	}
///
/// 	extension UIViewController
/// 	{
/// 		func showAlert( error: AlertRepresentableError, configuration: BasicAlertViewController.Configuration, completion: ( () -> Void )? = nil )
/// 		{
/// 			let alert: BasicAlertViewController = .init( error: error, configuration: configuration )
/// 			present( alert, animated: true, completion: completion )
/// 		}
/// 	}
