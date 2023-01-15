//
//  RemoteLog.swift
//  RemoteLog
//
//  Created by Adrian Ilie on 06.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit
import Core
import CoreDataManager

public final class RemoteLog {
	public enum Constants {
		/// Error identifier for ignoring log entries
		///
		/// Any log calls using this identifier (fully or in part) will be silently ignored.
		/// This is required because components implementing `RemoteLogUploadServiceProvider` use Core's networking layer,
		/// which include automatic calls to RemoteLog.
		public static let errorIdentifierIgnored = "RemoteLog.Err.Identifier.Ignored"
	}

	public static let shared = RemoteLog(
		repository: RemoteLogCoreDataRepository()
	)
	
	/// App remote logging identifier
	public private(set) var snApplication: String {
		get {
			repository.snApplication
		}
		set {
			repository.snApplication = newValue
		}
	}
	
	public init(repository: RemoteLogRepositoryProvider, uploadService: RemoteLogUploadServiceProvider? = nil) {
		self.repository = repository
		self.uploadService = uploadService
	}
	
	// MARK: - Repository
	
	private var repository: RemoteLogRepositoryProvider
	
	// MARK: - Upload
	
	private var uploadScheduler: RemoteLogUploadScheduler?
	var uploadService: RemoteLogUploadServiceProvider? {
		didSet {
			// clear scheduler if no upload service available
			guard let uploadService = uploadService else {
				uploadScheduler = nil
				return
			}
			
			// ensure a scheduler exists
			if uploadScheduler == nil {
				uploadScheduler = RemoteLogUploadScheduler(repository: self.repository, uploadService: uploadService)
			}
		}
	}
	
	// MARK: - Logging

	/**
	 Keys for storing data in UserSettings
	 
	 We're not using the `@UserDefault` as importing it will result in a circular dependency.
	*/
	enum UserSetting {
		static let defaultsSuite = "user"
		static let keyMessagesCount = "logMessagesCount"

		static var logMessagesCount: Int {
			get {
				guard let defaults = UserDefaults(suiteName: UserSetting.defaultsSuite) else { return 0 }
				guard let messagesCount = defaults.object(forKey: UserSetting.keyMessagesCount) as? Int else { return 0 }
				return messagesCount
			}
			set {
				guard let defaults = UserDefaults(suiteName: UserSetting.defaultsSuite) else { return }
				defaults.set(newValue, forKey: UserSetting.keyMessagesCount)
			}
		}
	}
	
	/**
	 Start the upload loop.

	 - parameter snApplication: App remote logging identifier
	 */
	public func start(snApplication: String) {
		self.snApplication = snApplication
		Task { await self.uploadScheduler?.start() }
	}

	/**
	 Stop the upload loop
	 */
	public func stop() {
		Task { await self.uploadScheduler?.stop() }
	}
	
	/**
	 Filter error identifier name, by removing unwanted substrings or prefixes.
	 
	 - parameter identifier: unfiltered identifier
	 - returns filtered identifier
	 */
	private func filterErrorIdentifier(_ identifier: String) -> String {
		var filteredIdentifier = identifier
		
		// remove unwanted strings, such as those added by Swift's Lietrals `#fileID` or `#function`
		[
			"/": ".",
			".swift": "",
			"()": ""
		].forEach {
			filteredIdentifier = filteredIdentifier.replacingOccurrences(of: $0, with: $1)
		}
		
		// remove "iOS" prefix from identifier if present
		if filteredIdentifier.count >= 4 {
			let endIndex = identifier.index(filteredIdentifier.startIndex, offsetBy: 4)
			let range = filteredIdentifier.startIndex ..< endIndex
			if filteredIdentifier[range].lowercased() == "ios." {
				filteredIdentifier.removeSubrange(range)
			}
		}
		
		return filteredIdentifier
	}
	
	func log(
		_ errorIdentifier: String,
		errorDescription: String,
		errorMessage: String? = nil,
		networkError: String? = nil,
		level: RemoteLogEntry.Level,
		receiptID: String? = nil,
		requestUrl: String? = nil,
		requestBody: String? = nil,
		exception: [String]? = Thread.callStackSymbols,
		customProperties: [String: Any]? = nil,
		userIdentifier: Int? = nil
	) {
		// Create new log entry with all mandatory fields set
		Task.detached {
			// check if log entry should be ignored
			guard !errorIdentifier.contains(Constants.errorIdentifierIgnored) else { return }
			
			let identifier = self.filterErrorIdentifier(errorIdentifier)
			
			var logEntry = RemoteLogEntry(
				level: level, timestamp: Date(), snApplication: self.snApplication, errorIdentifier: identifier, errorDescription: errorDescription,
				environment: .init(), properties: .init(custom: [:])
			)
			
			// Set the sequence ID according to the current number of logs
			logEntry.sequenceId = UserSetting.logMessagesCount + 1
			UserSetting.logMessagesCount += 1
			
			// Set the member ID and authentication token if we have them.
			// Set for regular and freemium user.
			if let memberId = userIdentifier {
				logEntry.properties?.memberNumber = memberId
			}

			// Set optional fields
			logEntry.properties?.receiptId = receiptID
			if let error = RemoteLogEntry.Properties.NetworkError(rawValue: networkError ?? "") {
				logEntry.properties?.networkError = error
			}
			
			// Iterate over all properties providers and add their properties to the `customProperties` dictionary.
			// Note: Duplicate custom properties are overriden
			customProperties?.forEach({ (key: String, value: Any) in
				logEntry.properties?.custom?[key] = AnyCodable(value)
			})

			// Set the error message
			if let errorMessage = errorMessage {
				logEntry.properties?.errorMessage = errorMessage
			}
			
			// Set the request URL
			if let requestUrl = requestUrl {
				logEntry.properties?.requestUrl = requestUrl
			}
			
			// Set request body
			// Don't log anything with PIN number
			if let requestBody = requestBody, !requestBody.contains("\"pin\"") {
				logEntry.properties?.requestBody = requestBody
			}

			// Set exception
			if var exception = exception {
				if exception.count > 0 {
					// Remove the first item in the trace which is the logError call itself
					exception.removeFirst()
				}
				logEntry.exception = exception.joined(separator: "\n")
			}

			// Set code version
			if let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String,
				let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
				logEntry.properties?.codeVersion = "iOS \(version) build \(build)"
			}
			
			logEntry.environment?.osVersion = await UIDevice.current.systemVersion
			logEntry.environment?.deviceModel = await UIDevice.current.modelName
			logEntry.environment?.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
			logEntry.environment?.deviceManufacturer = "Apple"
			
			do {
				try await self.repository.scheduleForTransfer(logEntry)
			} catch {
				print("Error saving remote log: \(error)")
			}
		}
	}
}
