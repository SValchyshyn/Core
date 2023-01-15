//
//  Helpers.swift
//  UnleashFeatureManager
//
//  Created by Marian Hunchak on 13.09.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

/**
Convert a semantic version string to an integer. For example version "19.1.1" -becomes 190101
String must be in semantic version format e.g. "1.0.2" or "1.2"

- returns: An integer representation of the version
*/
public func integerFromVersionString(_ version: String) -> Int {
	let versionElements = version.split(separator: ".")
	var finalVersion = ""
	versionElements.forEach {
		finalVersion += String($0).count < 2 ? "0" + $0 : $0
	}
	// If we have a version like 19.1 append 00 to match the rule and have a 6 digits number
	if versionElements.count == 2 {
		finalVersion += "00"
	}
	return Int(finalVersion) ?? 0
}

public func getAppVersion() -> String? {
	Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
}
