//
//  RemoteLogCDEntity+CoreDataProperties.swift
//  RemoteLog
//
//  Created by Niels Nørskov on 08/12/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import Foundation

public extension RemoteLogCDEntity {
	@NSManaged var errorIdentifier: String?
	@NSManaged var errorDescription: String?
	@NSManaged var errorMessage: String?
	@NSManaged var memberNumber: NSNumber?
	@NSManaged var receiptID: String?
	@NSManaged var mobileDankortSessionID: String?
	@NSManaged var requestBody: String?
	@NSManaged var timestamp: Date?
	@NSManaged var retryCount: Int64
	@NSManaged var rawLevel: String?
	@NSManaged var rawNetworkError: String?
	@NSManaged var sequenceID: NSNumber?
	@NSManaged var exception: String?
	@NSManaged var codeVersion: String?
	@NSManaged var requestURL: String?
	@NSManaged var osVersion: String?
	@NSManaged var appVersion: String?
	@NSManaged var deviceModel: String?
	@NSManaged var deviceManufacturer: String?
	@NSManaged var customPropertiesJSON: String?
}
