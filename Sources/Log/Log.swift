//
//  Log.swift
//  Log
//
//  Created by Adrian Ilie on 21.10.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Logging

public struct Log {
	/// Log collector for technical and development related events.
	public static var technical = Logger(label: "technical", factory: { _ in
		if #available(iOS 14.0, *) {
			return ConsoleLogHandler()
		} else {
			return ConsoleLegacyLogHandler()
		}
	})
	
	/// Log collector for business related events.
	public static var business = Logger(label: "business", factory: { _ in
		if #available(iOS 14.0, *) {
			return ConsoleLogHandler()
		} else {
			return ConsoleLegacyLogHandler()
		}
	})

	// MARK: - Metadata
	
	/// Custom metadata providers for all logging messages
	public static var metadataProviders: [LogMetadataProvider] = []
	
	/// Metadata provider for user information
	public static var metadataUserProvider: LogUserMetadataProvider?
}
