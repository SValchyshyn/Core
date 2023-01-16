//
//  CustomAlertButton.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 30/07/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import Core

/// Used to force the Alert's button to be defined in an as type-safe way as possible.
public protocol AlertButtonTitleRepresentable {
	/// Title of the `button` that the implementer should represent.
	var title: String { get }

	/// How shoud the button look
	var buttonStyle: AlertButtonStyle { get }
}

/// Defines if the button should be round or underlined
public enum AlertButtonStyle {
	/// The classic button with round corners used through the app
	case regular

	/// An underlined text which acts as a button
	case underlined
}

public extension BasicAlertViewController {

	/// Defines all the possible types of buttons that the alert can have.
	enum DefaultButtonTitle: AlertButtonTitleRepresentable {
		case ok
		case cancel
		case yes
		case no	
		case retry
		case custom( title: String, buttonStyle: AlertButtonStyle = .regular ) // to be removed once we remove the legacy code.

		/// Localized title of the `button`.
		public var title: String {
			switch self {
			case .ok:
				return CoreLocalizedString( "button_ok" )

			case .cancel:
				return CoreLocalizedString( "button_cancel_annuller" )

			case .yes:
				return CoreLocalizedString( "button_yes" )

			case .no:
				return CoreLocalizedString( "button_no" )

			case .retry:
				return CoreLocalizedString( "button_retry" )

			case .custom( let title, _ ):
				return title
			}
		}

		/// How should the button look
		public var buttonStyle: AlertButtonStyle {
			switch self {
			case .custom(_, let style):
				// We forward the style defined from customization
				return style

			default:
				// All the default buttons have regular rounder corners style
				return .regular
			}
		}
	}
}
