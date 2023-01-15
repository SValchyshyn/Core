//
//  RemoteLogEntry.swift
//  RemoteLog
//
//  Created by Adrian Ilie on 09.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Core

public struct RemoteLogEntry: Equatable, Codable {
	private struct Constants {
		static let currentSchemeVersion = "2.0"
	}

	public enum EntryError: Error {
		case missingRequiredValue(String)
	}
	
	public enum Level: String {
		case fatal 		= "Fatal"
		case error 		= "Error"
		case warning 	= "Warning"
		case info 		= "Info"
		case trace 		= "Trace"
		case unknown 	= "Unknown"
	}
	public internal(set) var level: Level?
	
	public internal(set) var timestamp: Date?

	public internal(set) var snApplication: String?
	public internal(set) var errorIdentifier: String?
	public internal(set) var errorDescription: String?
	public internal(set) var exception: String?
	public internal(set) var sequenceId: Int?
	
	public internal(set) var environment: Environment?
	public internal(set) var properties: Properties?
	public var metadata: Metadata? {
		guard let snApplication = snApplication, let errorIdentifier = errorIdentifier else {
			return nil
		}

		return Metadata(applicationId: snApplication, eventId: errorIdentifier)
	}
	
	public init(
		level: Level? = nil,
		timestamp: Date? = nil,
		snApplication: String? = nil,
		errorIdentifier: String? = nil,
		errorDescription: String? = nil,
		exception: String? = nil,
		sequenceId: Int? = nil,
		environment: Environment? = nil,
		properties: Properties? = nil
	) {
		self.level = level
		self.timestamp = timestamp
		self.snApplication = snApplication
		self.errorIdentifier = errorIdentifier
		self.errorDescription = errorDescription
		self.exception = exception
		self.sequenceId = sequenceId
		self.environment = environment
		self.properties = properties
	}
	
	// MARK: - Equatable
	
	public static func == (lhs: RemoteLogEntry, rhs: RemoteLogEntry) -> Bool {
		return (
			lhs.level == rhs.level &&
			lhs.timestamp == rhs.timestamp &&
			lhs.snApplication == rhs.snApplication &&
			lhs.errorIdentifier == rhs.errorIdentifier &&
			lhs.errorDescription == rhs.errorDescription &&
			lhs.exception == rhs.exception &&
			lhs.sequenceId == rhs.sequenceId &&
			lhs.environment == rhs.environment &&
			lhs.properties == rhs.properties &&
			lhs.metadata == rhs.metadata
		)
	}
	
	// MARK: - Codable
	
	public enum CodingKeys: String, CodingKey {
		// Required
		case schemaVersion = "schema_version"
		case timestamp
		case message
		case level
		case sequenceId = "sequence_id"
		
		// Optional
		case exception
		case metadata
		case environment
		case properties

		// Non-persistant
		case eventId = "event_id"
		case applicationId = "application_id"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.errorDescription = try container.decode(String.self, forKey: .message)
		
		let timestamp = try container.decode(String.self, forKey: .timestamp)
		self.timestamp = RemoteLogEntry.utcFormatterWithMilliseconds.date(from: timestamp)
		
		self.level = Level(rawValue: try container.decode(String.self, forKey: .level))
		self.snApplication = try container.decode(String.self, forKey: .applicationId)
		self.errorIdentifier = try container.decode(String.self, forKey: .eventId)
		self.exception = try container.decode(String.self, forKey: .exception)
		self.sequenceId = try container.decode(Int.self, forKey: .sequenceId)
		
		self.environment = try container.decode(Environment.self, forKey: .environment)
		self.properties = try container.decode(Properties.self, forKey: .properties)
	}
	
	public func encode(to encoder: Encoder) throws {
		guard let errorIdentifier = errorIdentifier else { throw EntryError.missingRequiredValue("errorIdentifier") }
		guard let timestamp = timestamp else { throw EntryError.missingRequiredValue("timestamp") }
		guard let description = errorDescription else { throw EntryError.missingRequiredValue("errorDescription") }
		guard let level = level else { throw EntryError.missingRequiredValue("level") }
		guard let snApplication = snApplication else { throw EntryError.missingRequiredValue("snApplication") }
		
		var container = encoder.container(keyedBy: CodingKeys.self)

		// Add required fields
		try container.encode(description, forKey: .message)
		try container.encode(Constants.currentSchemeVersion, forKey: .schemaVersion)
		try container.encode(RemoteLogEntry.utcFormatterWithMilliseconds.string(from: timestamp), forKey: .timestamp)
		try container.encode(level.rawValue, forKey: .level)
		try container.encode(snApplication, forKey: .applicationId)
		try container.encode(errorIdentifier, forKey: .eventId)
		
		// Metadata is only required for Eventlog v1
		try container.encode(metadata, forKey: .metadata)

		// Add optional root fields
		try container.encode(exception, forKey: .exception)
		try container.encode(sequenceId, forKey: .sequenceId)
		try container.encode(environment, forKey: .environment)
		try container.encode(properties, forKey: .properties)
	}
	
	/**
	UTC date formatter with milliseconds.
	*/
	static let utcFormatterWithMilliseconds: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		formatter.timeZone = TimeZone(abbreviation: "UTC")!
		formatter.locale = Locale(identifier: "en_US_POSIX")	// Enforce the format even if the user changes to AM/PM format
		return formatter
	}()
}

// MARK: - RemoteLogEntry.Metdata

extension RemoteLogEntry {
	public struct Metadata: Equatable, Codable {
		public let applicationId: String
		public let eventId: String
		
		init(applicationId: String, eventId: String) {
			self.applicationId = applicationId
			self.eventId = eventId
		}
		
		// MARK: - Equatable
		
		public static func == (lhs: Metadata, rhs: Metadata) -> Bool {
			return (
				lhs.applicationId == rhs.applicationId &&
				lhs.eventId == rhs.eventId
			)
		}
		
		// MARK: - Codable
		
		public enum CodingKeys: String, CodingKey {
			case applicationId = "application_id"
			case eventId = "application_event_id"
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			self.applicationId = try container.decode(String.self, forKey: .applicationId)
			self.eventId = try container.decode(String.self, forKey: .eventId)
		}
		
		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			
			try container.encode(applicationId, forKey: .applicationId)
			try container.encode(eventId, forKey: .eventId)
		}
	}
}

// MARK: - RemoteLogEntry.Environment

extension RemoteLogEntry {
	public struct Environment: Equatable, Codable {
		public internal(set) var deviceModel: String?
		public internal(set) var deviceManufacturer: String?
		public internal(set) var osVersion: String?
		public internal(set) var appVersion: String?
		
		public init(deviceModel: String? = nil, deviceManufacturer: String? = nil, osVersion: String? = nil, appVersion: String? = nil) {
			self.deviceModel = deviceModel
			self.deviceManufacturer = deviceManufacturer
			self.osVersion = osVersion
			self.appVersion = appVersion
		}
		
		// MARK: - Equatable
		
		public static func == (lhs: Environment, rhs: Environment) -> Bool {
			return (
				lhs.deviceModel == rhs.deviceModel &&
				lhs.deviceManufacturer == rhs.deviceManufacturer &&
				lhs.osVersion == rhs.osVersion &&
				lhs.appVersion == rhs.appVersion
			)
		}
		
		// MARK: - Codable
		
		public enum CodingKeys: String, CodingKey {
			case deviceModel = "model"
			case deviceManufacturer = "manufacturer"
			case osVersion = "os_version"
			case appVersion = "app_version"
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			self.deviceModel = try container.decode(String.self, forKey: .deviceModel)
			self.deviceManufacturer = try container.decode(String.self, forKey: .deviceManufacturer)
			self.osVersion = try container.decode(String.self, forKey: .osVersion)
			self.appVersion = try container.decode(String.self, forKey: .appVersion)
		}
		
		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			
			try container.encode(deviceModel, forKey: .deviceModel)
			try container.encode(deviceManufacturer, forKey: .deviceManufacturer)
			try container.encode(osVersion, forKey: .osVersion)
			try container.encode(appVersion, forKey: .appVersion)
		}
	}
}

// MARK: - RemoteLogEntry.Properties

extension RemoteLogEntry {
	public struct Properties: Equatable, Codable {
		public internal(set) var requestUrl: String?
		public internal(set) var requestBody: String?
		public internal(set) var errorMessage: String?
		public internal(set) var codeVersion: String?
		public internal(set) var receiptId: String?
		public internal(set) var mobileDankortSessionId: String?
		public internal(set) var memberNumber: Int?

		public enum NetworkError: String {
			case timeout 	= "Timeout"
			case other 		= "Other"
		}
		public internal(set) var networkError: NetworkError?
		
		public internal(set) var custom: [String: AnyCodable]?
		
		public init(
			requestUrl: String? = nil,
			requestBody: String? = nil,
			errorMessage: String? = nil,
			codeVersion: String? = nil,
			receiptId: String? = nil,
			mobileDankortSessionId: String? = nil,
			memberNumber: Int? = nil,
			networkError: NetworkError? = nil,
			custom: [String: AnyCodable]? = nil
		) {
			self.requestUrl = requestUrl
			self.requestBody = requestBody
			self.errorMessage = errorMessage
			self.codeVersion = codeVersion
			self.receiptId = receiptId
			self.mobileDankortSessionId = mobileDankortSessionId
			self.memberNumber = memberNumber
			self.networkError = networkError
			self.custom = custom
		}
		
		// MARK: - Equatable
		
		public static func == (lhs: Properties, rhs: Properties) -> Bool {
			return (
				lhs.requestUrl == rhs.requestUrl &&
				lhs.requestBody == rhs.requestBody &&
				lhs.errorMessage == rhs.errorMessage &&
				lhs.codeVersion == rhs.codeVersion &&
				lhs.codeVersion == rhs.codeVersion &&
				lhs.receiptId == rhs.receiptId &&
				lhs.mobileDankortSessionId == rhs.mobileDankortSessionId &&
				lhs.memberNumber == rhs.memberNumber &&
				lhs.networkError == rhs.networkError &&
				lhs.custom == rhs.custom
			)
		}
		
		// MARK: - Codable
		
		struct DynamicKeys: CodingKey {
			var stringValue: String
			var intValue: Int?

			init(stringValue: String) {
				self.stringValue = stringValue
			}

			init(intValue: Int) {
				self.intValue = intValue
				self.stringValue = String(describing: intValue)
			}
		}
		
		public enum CodingKeys: String, CaseIterable {
			case requestUrl = "request_url"
			case requestBody = "request_body"
			case errorMessage = "error_message"
			case codeVersion = "code_version"
			case receiptId = "receipt_id"
			case mobileDankortSessionId = "mdk_sessionId"
			case memberNumber = "membership_id"
			case networkError = "network_error"
		}
		
		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: DynamicKeys.self)
			
			self.requestUrl = try container.decode(String.self, forKey: .init(stringValue: CodingKeys.requestUrl.rawValue))
			self.requestBody = try container.decode(String.self, forKey: .init(stringValue: CodingKeys.requestBody.rawValue))
			self.errorMessage = try container.decode(String.self, forKey: .init(stringValue: CodingKeys.errorMessage.rawValue))
			self.codeVersion = try container.decode(String.self, forKey: .init(stringValue: CodingKeys.codeVersion.rawValue))
			self.receiptId = try container.decode(String.self, forKey: .init(stringValue: CodingKeys.receiptId.rawValue))
			self.mobileDankortSessionId = try container.decode(String.self, forKey: .init(stringValue: CodingKeys.mobileDankortSessionId.rawValue))
			self.memberNumber = try container.decode(Int.self, forKey: .init(stringValue: CodingKeys.memberNumber.rawValue))
			
			let networkErrorRawValue = try container.decode(String.self, forKey: .init(stringValue: CodingKeys.networkError.rawValue))
			self.networkError = .init(rawValue: networkErrorRawValue)
			
			// parse custom attributes
			try container.allKeys.forEach { key in
				let expectedKeys = CodingKeys
					.allCases
					.map { codingKey in
						codingKey.rawValue
					}
				
				if !expectedKeys.contains(key.stringValue) { // if a received key is not expected, it's considered a custom attribute
					if custom == nil { self.custom = [:] } // initialize custom attributes holder
					
					self.custom![key.stringValue] = try container.decode(AnyCodable.self, forKey: key)
				}
			}
		}
		
		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: DynamicKeys.self)

			try container.encodeIfPresent(requestUrl, forKey: .init(stringValue: CodingKeys.requestUrl.rawValue))
			try container.encodeIfPresent(requestBody, forKey: .init(stringValue: CodingKeys.requestBody.rawValue))
			try container.encodeIfPresent(errorMessage, forKey: .init(stringValue: CodingKeys.errorMessage.rawValue))
			try container.encodeIfPresent(codeVersion, forKey: .init(stringValue: CodingKeys.codeVersion.rawValue))
			try container.encodeIfPresent(receiptId, forKey: .init(stringValue: CodingKeys.receiptId.rawValue))
			try container.encodeIfPresent(mobileDankortSessionId, forKey: .init(stringValue: CodingKeys.mobileDankortSessionId.rawValue))
			try container.encodeIfPresent(memberNumber, forKey: .init(stringValue: CodingKeys.memberNumber.rawValue))
			try container.encodeIfPresent(networkError?.rawValue, forKey: .init(stringValue: CodingKeys.networkError.rawValue))
			
			// parse custom attributes
			if let customProperties = custom {
				for (customKey, customValue) in customProperties {
					try container.encode(customValue, forKey: .init(stringValue: customKey))
				}
			}
		}
	}
}
