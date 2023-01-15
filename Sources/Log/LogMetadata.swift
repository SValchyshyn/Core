//
//  LogMetadata.swift
//  Log
//
//  Created by Adrian Ilie on 21.10.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import os
import Logging
import Core

public enum LogMetadataKey: String {
	case identifier
	case error
	case errorDescription
	case requestUrl
	case requestBody
	case receiptId
}

public enum LogMetadata: Hashable, Equatable {
	case identifier(String)
	case error(Error)
	case urlRequest(URLRequest)
	case receiptId(String)
	case customBool(key: String, value: Bool?)
	case customInt(key: String, value: Int?)
	case customFloat(key: String, value: Double?)
	case customString(key: String, value: String?)
	case customCodable(key: String, value: AnyCodable?)
	
	// MARK: - Hashable
	
	public func hash(into hasher: inout Hasher) {
		switch self {
		case .identifier(let identifier):
			hasher.combine(identifier)

		case .error(let error):
			hasher.combine(error.localizedDescription)
			
		case .urlRequest(let request):
			hasher.combine(request.url?.absoluteString)
			
		case .receiptId(let id):
			hasher.combine(id)
			
		case .customBool(let key, let value):
			hasher.combine(key)
			hasher.combine(value)
			
		case .customInt(let key, let value):
			hasher.combine(key)
			hasher.combine(value)
			
		case .customFloat(let key, let value):
			hasher.combine(key)
			hasher.combine(value)
			
		case .customString(let key, let value):
			hasher.combine(key)
			hasher.combine(value)
			
		case .customCodable(let key, let value):
			hasher.combine(key)
			hasher.combine(value)
		}
	}
	
	// MARK: - Equatable
	
	public static func == (lhs: LogMetadata, rhs: LogMetadata) -> Bool {
		switch (lhs, rhs) {
		case (.identifier(let lIdentifier), .identifier(let rIdentifier)):
			return lIdentifier == rIdentifier
			
		case (.error(let lError), .error(let rError)):
			return lError.localizedDescription == rError.localizedDescription
			
		case (.urlRequest(let lRequest), .urlRequest(let rRequest)):
			return (
				lRequest.url?.absoluteString ?? ""
				==
				rRequest.url?.absoluteString ?? ""
			)
			
		case (.receiptId(let lId), .receiptId(let rId)):
			return lId == rId
			
		case (.customBool(let lKey, let lValue), .customBool(let rKey, let rValue)):
			return (lKey == rKey) && (lValue == rValue)
			
		case (.customInt(let lKey, let lValue), .customInt(let rKey, let rValue)):
			return (lKey == rKey) && (lValue == rValue)
			
		case (.customFloat(let lKey, let lValue), .customFloat(let rKey, let rValue)):
			return (lKey == rKey) && (lValue == rValue)
			
		case (.customString(let lKey, let lValue), .customString(let rKey, let rValue)):
			return (lKey == rKey) && (lValue == rValue)
			
		case (.customCodable(let lKey, let lValue), .customCodable(let rKey, let rValue)):
			return (lKey == rKey) && (lValue == rValue)
			
		default:
			return false
		}
	}
}

public extension Array where Element == LogMetadata {
	// swiftlint:disable cyclomatic_complexity - it's clear enough
	func toMetadata() -> Logging.Logger.Metadata? {
		var metadata: Logging.Logger.Metadata = [:]
		
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		
		for item in self {
			switch item {
			case .identifier(let identifier):
				metadata[LogMetadataKey.identifier.rawValue] = .string(identifier)
				
			case .error(let error):
				metadata[LogMetadataKey.error.rawValue] = .string(String(describing: error))
				metadata[LogMetadataKey.errorDescription.rawValue] = .string(error.localizedDescription)
				
			case .urlRequest(let request):
				if let url = request.url {
					metadata[LogMetadataKey.requestUrl.rawValue] = .string(url.absoluteString)
				}
				
				if let bodyData = request.httpBody,
				   let requestBodyString = String(data: bodyData, encoding: String.Encoding.utf8),
				   !requestBodyString.contains("\"pin\"") {
					metadata[LogMetadataKey.requestBody.rawValue] = .string(requestBodyString)
				}

			case .receiptId(let id):
				metadata[LogMetadataKey.receiptId.rawValue] = .string(id)
				
			case .customBool(let key, let value):
				guard let data = try? encoder.encode(value) else { continue }
				guard let string = String(data: data, encoding: .utf8) else { continue }
				metadata[key] = .string(string)
				
			case .customInt(let key, let value):
				guard let data = try? encoder.encode(value) else { continue }
				guard let string = String(data: data, encoding: .utf8) else { continue }
				metadata[key] = .string(string)
				
			case .customFloat(let key, let value):
				var data: Data?
				if let value = value {
					data = try? encoder.encode(Decimal(value))
				} else {
					data = try? encoder.encode(nil as String?)
				}
				guard let data = data else { continue }
				guard let string = String(data: data, encoding: .utf8) else { continue }
				metadata[key] = .string(string)
				
			case .customString(let key, let value):
				guard let data = try? encoder.encode(value) else { continue }
				guard let string = String(data: data, encoding: .utf8) else { continue }
				metadata[key] = .string(string)
				
			case .customCodable(let key, let value):
				guard let data = try? encoder.encode(value) else { continue }
				guard let string = String(data: data, encoding: .utf8) else { continue }
				metadata[key] = .string(string)
			}
		}
		
		return metadata
	}
}
