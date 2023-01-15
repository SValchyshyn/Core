//
//  Logger-Extension.swift
//  Log
//
//  Created by Adrian Ilie on 21.10.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Logging

public extension Logging.Logger.MetadataValue {
	/// String value of metadata.
	var stringValue: String? {
		guard case let .string(value) = self else { return nil }
		return value
	}
}

public extension Logger {
	/**
	 Log a message and it's metadata and send it to all handlers registered.
	 This is the de-facto logging method that should be used everywhere in order for the metadata to be processed correctly (any future extension should call this method).
	 
	 - parameter level: log level to log `message` at. For the available log levels, see `Logger.Level`
	 - parameter message: message to be logged. `message` can be used with any string interpolation literal
	 - parameter metadata: one-off metadata to attach to this log message
	 - parameter file: file this log message originates from
	 - parameter function: function this log message originates from
	 - parameter line: line this log message originates from
	 */
	func log(
		_ level: Logger.Level,
		_ message: String,
		_ metadata: [LogMetadata] = [],
		file: String = #fileID,
		function: String = #function,
		line: UInt = #line
	) {
		log(level: level, Logger.Message(stringLiteral: message), metadata: metadata.toMetadata(), file: file, function: function, line: line)
	}
	
	/**
	 Log a network specific error and send it to all handlers registered.
	 
	 - parameter error: instance of Error triggered
	 - parameter origin: human readable origin point of the error
	 - parameter metadata: one-off metadata to attach to this log message
	 - parameter metadataUserProvider: component providing user specific metadata, defaults to `Log.metadataUserProvider`
	 */
	func logNetworkError(
		_ error: Error,
		origin: String,
		_ metadata: [LogMetadata] = [],
		metadataUserProvider: LogUserMetadataProvider? = Log.metadataUserProvider
	) {
		// process user identifier
		var memberID = "unknown"
		if let metadataProvider = metadataUserProvider, let userMetadata = metadataProvider.userMetadata {
			switch userMetadata {
			case .customInt(_, let userId):
				if let userId = userId {
					memberID = "\(userId)"
				}
				
			case .customString(_, let userId):
				if let userId = userId {
					memberID = userId
				}
				
			default:
				break
			}
		}
		
		// compose metadata
		var completeMetadata = metadata
		completeMetadata.append(.error(error))

		// log error
		if (error as NSError).code == NSURLErrorTimedOut {
			log(.error, "Timeout error during \(origin) for member \(memberID)", completeMetadata)
		} else {
			log(.error, "Network error during \(origin) for member \(memberID)", completeMetadata)
		}
	}
}
