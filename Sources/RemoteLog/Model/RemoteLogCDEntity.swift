//
//  RemoteLogCDEntity.swift
//  RemoteLog
//
//  Created by Georgi Damyanov on 30/11/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import Foundation
import CoreData
import Core

public class RemoteLogCDEntity: NSManagedObject {
	// MARK: - RemoteLogEntry
	
	/**
	 Map RemoteLogCDEntity data from RemoteLogEntry.
	 
	 - parameter model: log entry
	 */
	func fromModel(_ model: RemoteLogEntry) {
		errorIdentifier = model.errorIdentifier
		errorDescription = model.errorDescription
		errorMessage = model.properties?.errorMessage
		if let memberNumber = model.properties?.memberNumber { self.memberNumber = NSNumber(value: memberNumber) }
		receiptID = model.properties?.receiptId
		mobileDankortSessionID = model.properties?.mobileDankortSessionId
		requestBody = model.properties?.requestBody
		timestamp = model.timestamp
		rawLevel = model.level?.rawValue
		rawNetworkError = model.properties?.networkError?.rawValue
		if let sequenceId = model.sequenceId { self.sequenceID = NSNumber(value: sequenceId) }
		exception = model.exception
		codeVersion = model.properties?.codeVersion
		requestURL = model.properties?.requestUrl
		osVersion = model.environment?.osVersion
		appVersion = model.environment?.appVersion
		deviceModel = model.environment?.deviceModel
		deviceManufacturer = model.environment?.deviceManufacturer
		
		let encoder = JSONEncoder()
		if let data = try? encoder.encode(model.properties?.custom) {
			customPropertiesJSON = String(data: data, encoding: .utf8)
		}
	}
	
	/**
	 Map RemoteLogCDEntity data to RemoteLogEntry.
	 
	 - returns: mapped entry
	 */
	func toModel() -> RemoteLogEntry {
		var entryProperties = RemoteLogEntry.Properties(
			requestUrl: requestURL, requestBody: requestBody,
			errorMessage: errorMessage,
			codeVersion: codeVersion, receiptId: receiptID, mobileDankortSessionId: mobileDankortSessionID, memberNumber: memberNumber?.intValue
		)
		
		if let networkError = RemoteLogEntry.Properties.NetworkError(rawValue: rawNetworkError ?? "") {
			entryProperties.networkError = networkError
		}
		
		if let customPropertiesData = customPropertiesJSON?.data(using: .utf8) {
			let decoder = JSONDecoder()
			entryProperties.custom = try? decoder.decode([String: AnyCodable].self, from: customPropertiesData)
		}
		
		return RemoteLogEntry(
			level: .init(rawValue: rawLevel ?? ""),
			timestamp: timestamp,
			errorIdentifier: errorIdentifier,
			errorDescription: errorDescription,
			exception: exception,
			sequenceId: sequenceID?.intValue,
			environment: .init(deviceModel: deviceModel, deviceManufacturer: deviceManufacturer, osVersion: osVersion, appVersion: appVersion),
			properties: entryProperties
		)
	}
}
