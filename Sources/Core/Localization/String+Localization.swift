//
//  String+Localization.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 21.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public extension String {
	
	// MARK: Key localization
	
	/// Returns a localized string. Is just wrapper for `NSLocalizedString`.
	static func localized(for key: String, table: String? = nil, bundle: Bundle = .main, comment: String = "") -> String {
		// swiftlint:disable module_localization - This is the base API.
		NSLocalizedString(key, tableName: table, bundle: bundle, value: "", comment: comment)
	}
	
	/// Returns a localized string by checking in `main` bundle first to get app localization.
	/// If is not found then checks in provided module bundle for `dev` localization.
	static func moduleLocalized(for key: String, table: String, module: Bundle, comment: String = "") -> String {
		tryLocalize(for: key, table: nil, bundle: .main, comment: comment) // Try from app `main` bundle first
			?? localized(for: key, table: table, bundle: module, comment: comment)
	}
	
	/// Returns a localized string. In case key and localized string are equal returns `	nil`.
	private static func tryLocalize(for key: String, table: String?, bundle: Bundle, comment: String) -> String? {
		let localizedString = localized(for: key, table: table, bundle: bundle, comment: comment)
		return localizedString == key ? nil : localizedString
	}
	
	// MARK: Formatted key localization
	
	/// Returns a localized string formatted with provided arguments.
	static func localized(for key: String, arguments: [CVarArg], table: String? = nil, bundle: Bundle = .main, locale: Locale = .current, comment: String = "") -> String {
		String(
			format: localized(for: key, table: table, bundle: bundle, comment: comment),
			locale: locale,
			arguments: arguments)
	}
	
	/// Returns a localized string formatted with provided arguments.
	static func localized(for key: String, _ arguments: CVarArg..., table: String? = nil, bundle: Bundle = .main, locale: Locale = .current, comment: String = "") -> String {
		localized(for: key, arguments: Array(arguments), table: table, bundle: bundle, locale: locale, comment: comment)
	}
	
	/// Returns a localized string formatted with provided arguments by checking in `main` bundle first to get app localization.
	/// If is not found then checks in provided module bundle for `dev` localization.
	static func moduleLocalized(for key: String, arguments: [CVarArg], table: String, module: Bundle, locale: Locale = .current, comment: String = "") -> String {
		String(
			format: moduleLocalized(for: key, table: table, module: module, comment: comment),
			locale: locale,
			arguments: arguments)
	}
	
	/// Returns a localized string formatted with provided arguments by checking in `main` bundle first to get app localization.
	/// If is not found then checks in provided module bundle for `dev` localization.
	static func moduleLocalized(for key: String, _ arguments: CVarArg..., table: String, module: Bundle, locale: Locale = .current, comment: String = "") -> String {
		moduleLocalized(for: key, arguments: Array(arguments), table: table, module: module, locale: locale, comment: comment)
	}
	
	// MARK: Plural localization
	
	/// Localizes string by localization key and plural value.
	static func localizedPlural(for key: String, value: Int, table: String? = nil, bundle: Bundle = .main, locale: Locale = .current, comment: String = "") -> String {
		func localizedString(for category: LanguagePluralCategory) -> String? {
			tryLocalize(for: category.localizationKey(for: key), table: table, bundle: bundle, comment: comment)
		}
		
		return localizedString(for: locale.languagePluralCategory(for: value)) // Use locale category
			?? localizedString(for: .other) // Use "other" category
			?? key
	}
	
	/// Localizes string by localization key and plural value by checking in `main` bundle first to get app localization.
	/// If is not found then checks in provided module bundle for `dev` localization.
	static func moduleLocalizedPlural(for key: String, value: Int, table: String, module: Bundle, locale: Locale = .current, comment: String = "") -> String {
		func localizedString(for category: LanguagePluralCategory) -> String? {
			// Create key for plural localization
			let pluralKey = category.localizationKey(for: key)
			
			// Get localized string by key
			let localizedString = moduleLocalized(for: pluralKey, table: table, module: module, comment: comment)
			
			// Return `nil` if localized string equal
			return localizedString == pluralKey ? nil : localizedString
		}
		
		return localizedString(for: locale.languagePluralCategory(for: value)) // Use locale category
			?? localizedString(for: .other) // Use "other" category
			?? key
	}
	
}

private extension LanguagePluralCategory {
	
	func localizationKey(for key: String) -> String {
		"\(key).\(rawValue)"
	}
	
}
