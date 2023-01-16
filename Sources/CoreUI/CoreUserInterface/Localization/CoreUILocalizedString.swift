//
//  CoreUserInterfaceLocalizedString.swift
//  Core
//
//  Created by Roman Croitor on 15.09.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Core

// swiftlint:disable identifier_name
/// Calls `NSLocalizedString`on the `Bundle.main` first in order to check the availability of the localized string.
/// If that is not found, we default to the `dev` language provided in the module in which the function is defined.
/// - Parameters:
///   - key: An identifying value used to reference a localized string.
///   Don't use the empty string as a key. Values keyed by the empty string will
///   not be localized.
///   - comment: A note to the translator describing the context where
///   the localized string is presented to the user.
///   - args: Used to fill in the placeholders defines in the localization.
public func CoreUserInterfaceLocalizedString(_ key: String, comment: String = "", _ args: CVarArg...) -> String {
	ModuleLocalizedString(key, comment: comment, args, tableName: "CoreUserInterface", module: .CoreUIModule)
}
