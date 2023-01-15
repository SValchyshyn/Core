//
//  AlertRepresentableInfo.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 30/07/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

// MARK: - Local Errors example.

/// Local errors definition example:
///
/// `enum GeneralErrors`
/// {
///		/// Defines the error that the user should be seeing when the app is not connected to the internet.
///		`static let unreachable: AlertRepresentableInfo = CoopBaseError( titleKey: "", bodyKey: "" )`
/// }
///

// MARK: - Remote Errors example.

/// `enum PaymentAPIErrorCode: Int, Decodable`
/// {
///		`case notEnoughbalance 	= 1`
///		`case fraud				= 2`
///
///		fileprivate var error: AlertRepresentableInfo {
///			switch self {
///			`case .notEnoughbalance:`
///				`return CoopBaseError( titleKey: "", bodyKey: "" )`
///
///			`case .fraud:`
///				`return CoopBaseError( titleKey: "", bodyKey: "" )`
///			}
///		}
/// }
///
/// `class PaymentError: AlertRepresentableInfo, Decodable`
/// {
///		let title: String
///		let body: String
///
///		/// The `errorCode` for which the `title` and `body` are configured.
///		`let code: PaymentAPIErrorCode`
///
///		`fileprivate init( title: String, body: String, code: PaymentAPIErrorCode )`
///		{
///			self.title = title
///			self.body = body
///			self.code = code
///		}
///
///		`init( errorCode: PaymentAPIErrorCode )`
///		{
///			let error = errorCode.error
///			self.title = error.title
///			self.body = error.body
///			self.code = errorCode
///		}
///
///		`required convenience init( from decoder: Decoder ) throws`
///		{
///			let container = try decoder.singleValueContainer()
///			`self.init( errorCode: try container.decode( PaymentAPIErrorCode.self ) )`
///		}
///	}
///

// MAKR: - Same Error - Different Flow - Different texts

/// `final class WebPaymentError: PaymentError`
/// {
///		`override init( errorCode: PaymentAPIErrorCode )`
///		{
///			switch errorCode {
///			`case .notEnoughbalance:`
///				`super.init( title: "some new title", body: "some new body", code: errorCode )`
///
///			default:
///				`super.init( errorCode: errorCode )`
///			}
///		}
///
///		`required convenience init( from decoder: Decoder ) throws`
///		{
///			let container = try decoder.singleValueContainer()
///			`self.init( errorCode: try container.decode( PaymentAPIErrorCode.self ) )`
///		}
/// }

/// Defines an interface of basic information that an alert needs in order to display some relevant information.
public protocol AlertRepresentableInfo {
	/// Small text that should define the `type of the information` or a generic text to use as an `alert title`.
	var title: String { get }

	/// Comprehensive description of the situation for which we're presenting the `alert`.
	var body: String { get }
}

/// Defines an interface of attributed information that an alert needs in order to display some relevant information.
public protocol AlertRepresentableRichInfo: AlertRepresentableInfo {
	/// Attributed representation of the `title` property. Should maintain functionality.
	var attributedTitle: NSAttributedString? { get }

	/// Attributed representation of the `body` property. Should maintain functionaliy.
	var attributedBody: NSAttributedString? { get }
}

/// Defines the basic format that an `Error` should have in order to be easily representable in an `alert`.
public protocol AlertRepresentableError: AlertRepresentableInfo, Error { }
