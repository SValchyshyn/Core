//
//  AppError.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 11.11.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// Base error specific to the app. Comes with it's own title and messages that might be shown to the user.
public protocol AppError: Error {
	/// The localized title to display to the user
	var title: String { get }

	/// The localized message to display to the user
	var message: String { get }
}
