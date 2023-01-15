//
//  ConsoleLogHandler.swift
//  Log
//
//  Created by Adrian Ilie on 21.10.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import os
import Logging

@available(iOS 14.0, *)
public struct ConsoleLogHandler: LogHandler {
	private var log: os.Logger?

	public init() {
		if let bundleIdentifier = Bundle.main.bundleIdentifier {
			log = Logger(subsystem: bundleIdentifier, category: "General")
		}
	}
	
	// MARK: - LogHandler
	
	public var logLevel: Logging.Logger.Level = .trace
	
	public var metadata: Logging.Logger.Metadata = [:]
	
	public subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
		get {
			return metadata[metadataKey]
		}
		set {
			metadata[metadataKey] = newValue
		}
	}
	
	// swiftlint:disable function_parameter_count - interface provided by Apple as-is
	public func log(
		level: Logging.Logger.Level,
		message: Logging.Logger.Message,
		metadata: Logging.Logger.Metadata?,
		source: String,
		file: String,
		function: String,
		line: UInt
	) {
		guard let log = log else {
			NSLog("[\(level.rawValue.uppercased())] \(message)")
			return
		}
		
		log.log(level: level.osLevel, "[\(level.rawValue.uppercased())] \(message)")
	}
}

public struct ConsoleLegacyLogHandler: LogHandler {
	public init() {

	}
	
	// MARK: - LogHandler
	
	public var logLevel: Logging.Logger.Level = .trace
	
	public var metadata: Logging.Logger.Metadata = [:]
	
	public subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
		get {
			return metadata[metadataKey]
		}
		set {
			metadata[metadataKey] = newValue
		}
	}
	
	// swiftlint:disable function_parameter_count - interface provided by Apple as-is
	public func log(
		level: Logging.Logger.Level,
		message: Logging.Logger.Message,
		metadata: Logging.Logger.Metadata?,
		source: String,
		file: String,
		function: String,
		line: UInt
	) {
		NSLog("[\(level.rawValue.uppercased())] \(message)")
	}
}

// MARK: - Log level mapping

public extension Logging.Logger.Level {
	var osLevel: OSLogType {
		switch self {
		case .trace: return .debug
		case .debug: return .debug
		case .info: return .info
		case .notice: return .default
		case .warning: return .default
		case .error: return .error
		case .critical: return .error
		}
	}
}
