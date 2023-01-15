//
//  ModuleLocalizedString.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 25.08.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
/// Calls `NSLocalizedString`on the `Bundle.main` first in order to check the availability of the localized string.
/// If that is not found, we default to the `dev` language provided in the provided module.
/// - Parameters:
///   - key: An identifying value used to reference a localized string.
///   Don't use the empty string as a key. Values keyed by the empty string will
///   not be localized.
///   - comment: A note to the translator describing the context where
///   the localized string is presented to the user.
///   - args: Used to fill in the placeholders defines in the localization.
///   - tableName: The name of the table containing the localized string
///   identified by `key`. This is the prefix of the strings file—a file with
///   the `.strings` extension—containing the localized values.
///   - module: The bundle containing the table's strings file.
public func ModuleLocalizedString(_ key: String, comment: String = "", _ args: [CVarArg], tableName: String, module: Bundle) -> String {
	args.isEmpty
		? .moduleLocalized(for: key, table: tableName, module: module, comment: comment)
		: .moduleLocalized(for: key, arguments: args, table: tableName, module: module, comment: comment)
}
