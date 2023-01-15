//
//  CoreBaseError.swift
//  Core
//
//  Created by Roman Croitor on 15.09.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public struct LocalizationConfiguration {
	/// The `Bundle` from which the localization should be performed.
	public let bundle: Bundle

	/// Name of the file in which the localizations are found.
	public let tableName: String?

	/// - Parameters:
	///   - bundle: Default value: `.main`.
	///   - tableName: Default value: `nil`.
	public init( bundle: Bundle = .main, tableName: String? = nil ) {
		self.bundle = bundle
		self.tableName = tableName
	}
}

/// The most basic implementation of `AlertRepresentableError` as a concrete type.
public struct CoreBaseError: AlertRepresentableError {
	public let title: String
	public let body: String

	// MARK: - Custom init.

	public init( title: String, body: String ) {
		self.title = title
		self.body = body
	}

	/// - Parameters:
	///   - titleKey: The key by which the localized title resource is found in the `.strings` file.
	///   - bodyKey: The key by which the localized body resource is found in the `.strings` file.
	///   - config: Contains information about where to fetch the localizations from. Default value: `LocalizationConfiguration()` which leads to fetching the strings from `Bundle.main` and `Localizable.strings` file.
	public init( titleKey: String, bodyKey: String, config: LocalizationConfiguration = .init() ) {
		self.init(
			// Using the NSLocalizedString API here is fine since the `config` contains both the `tableName` and the `bundle` from which we should be extracting the localization. -FAIO
			title: NSLocalizedString( titleKey, tableName: config.tableName, bundle: config.bundle, value: "", comment: "" ), // swiftlint:disable:this module_localization - We're specifying the tableName and bundle, so it's fine to use the NSLocalizedString here.
			body: NSLocalizedString( bodyKey, tableName: config.tableName, bundle: config.bundle, value: "", comment: "" ) // swiftlint:disable:this module_localization - We're specifying the tableName and bundle, so it's fine to use the NSLocalizedString here.
		)
	}
}

/// The most basic implementation of `AlertRepresentableRichInfo`.
public struct CoreBaseRichInfo: AlertRepresentableRichInfo {
	public let title: String
	public let body: String = "" // The attributedBody will have precedence over the body. Leaving it empty should be fine.
	public let attributedTitle: NSAttributedString?
	public let attributedBody: NSAttributedString?

	// MARK: - Custom init.

	public init( title: String, attributedTitle: NSAttributedString?, attributedBody: NSAttributedString? ) {
		self.title = title
		self.attributedTitle = attributedTitle
		self.attributedBody = attributedBody
	}
}
