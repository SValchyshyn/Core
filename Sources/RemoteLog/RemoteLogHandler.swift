//
//  RemoteLogHandler.swift
//  RemoteLog
//
//  Created by Adrian Ilie on 24.10.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Logging
import Core
import Log

extension Logger.Level {
	/// Corresponding level in `RemoteLog`.
	var remoteLogLevel: RemoteLogEntry.Level {
		switch self {
		case .trace: return .trace
		case .debug: return .trace
		case .info: return .info
		case .notice: return .info
		case .warning: return .warning
		case .error: return .error
		case .critical: return .fatal
		}
	}
}

public struct RemoteLogHandler: LogHandler {
	let remoteLog: RemoteLog
	
	public init(
		remoteLog: RemoteLog
	) {
		self.remoteLog = remoteLog
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
		var errorIdentifier = "\(file).\(function)"
		if let errorIdentifierMeta = metadata?[LogMetadataKey.identifier.rawValue],
			  case let .string(errorIdentifierProvided) = errorIdentifierMeta {
			errorIdentifier = errorIdentifierProvided
		}
		
		// merge message metadata with all metadata providers registered
		var mergedMetadata = metadata ?? [:]
		Log.metadataProviders.forEach {
			guard let providerMetadata = $0.metadata?.toMetadata() else { return }
			providerMetadata.forEach { key, value in
				mergedMetadata[key] = value
			}
		}
		
		// process custom properties.
		// since SwiftLog's metadata works only with strings, we use JSON encoding for other types that are not strings
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601

		var customProperties: [String: Any] = [:]
		let excludedKeys = [LogMetadataKey.identifier.rawValue, LogMetadataKey.error.rawValue, LogMetadataKey.requestUrl.rawValue, LogMetadataKey.requestBody.rawValue, LogMetadataKey.receiptId.rawValue]
		for (key, value) in mergedMetadata {
			guard !excludedKeys.contains(key) else { continue }
			guard let stringValue = value.stringValue, let stringData = stringValue.data(using: .utf8) else { continue }
			
			// decode Bool
			do {
				customProperties[key] = try decoder.decode(Bool.self, from: stringData)
				continue
			} catch {}
			
			// decode Int
			do {
				customProperties[key] = try decoder.decode(Int.self, from: stringData)
				continue
			} catch {}
			
			// decode Float
			do {
				customProperties[key] = try decoder.decode(Double.self, from: stringData)
				continue
			} catch {}
			
			// decode String
			do {
				customProperties[key] = try decoder.decode(String.self, from: stringData)
				continue
			} catch {}
			
			// decode AnyCodable
			do {
				customProperties[key] = try decoder.decode(AnyCodable.self, from: stringData)
				continue
			} catch {}
		}
		
		// extract user identity from metadata provider if present
		var userId: Int?
		if let userProvider = Log.metadataUserProvider, let userMetadata = userProvider.userMetadata {
			switch userMetadata {
			case .customInt(_, let value): userId = value
			default: break
			}
		}
		
		// dispatch to RemoteLog
		remoteLog.log(
			errorIdentifier,
			errorDescription: message.description,
			errorMessage: metadata?[LogMetadataKey.error.rawValue]?.stringValue,
			networkError: nil,
			level: level.remoteLogLevel,
			receiptID: metadata?[LogMetadataKey.receiptId.rawValue]?.stringValue,
			requestUrl: metadata?[LogMetadataKey.requestUrl.rawValue]?.stringValue,
			requestBody: metadata?[LogMetadataKey.requestBody.rawValue]?.stringValue,
			customProperties: customProperties,
			userIdentifier: userId
		)
	}
}
