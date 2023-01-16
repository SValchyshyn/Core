//
//  MultipleBundlesLocalizedString.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 26.07.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable module_localization - This is the app specific API, we should be using this API instead of referring to the "Localizable" table explicitly.
/// Calls `NSLocalizedString`on the `Bundle.main` first in order to check the availability of the localized string.
/// If that is not found, we iterate through app preferred languages Bundles and search for a localisation there
/// - Parameters:
///   - key: An identifying value used to reference a localized string.
///   Don't use the empty string as a key. Values keyed by the empty string will
///   not be localized.
///   - comment: A note to the translator describing the context where
///   the localized string is presented to the user.
public func MultipleBundlesLocalizedString(_ key: String, comment: String = "") -> String {
	let localized = NSLocalizedString(key, comment: comment)
	
	// Check if we managed to get the localisation. A string key returned means no localisation for preferred language
	if localized != key {
		return localized
	} else {
		// We didn't manage to get the localisation for currently preferred language. Iterate over other preferred languages and try to get a localized value from there
		let preferredLocales = Locale.preferredLanguages.map{Locale(identifier: $0)}
		for locale in preferredLocales {
			if let path = Bundle.main.path(forResource: locale.languageCode, ofType: "lproj"), let bundle = Bundle(path: path) {
				let newLocalized = NSLocalizedString(key, bundle: bundle, comment: "")
				if newLocalized != key { return newLocalized }
			}
		}
		
		return localized
	}
}
