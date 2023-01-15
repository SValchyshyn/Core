//
//  FeatureStatusPropery+PropertyWrapper.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 21/11/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

/// A wrapper around retrieving values from the remote feature manager.
///	## Usage:
///	We declare a remote feature with a key and default status of type conforming to `FeatureStatus`
///	```
///	@FeatureStatusProperty( key: "core_clear_token_logs", defaultStatus: .disabled )
///	var clearExpiredTokenLogs: FeatureStatus
///	```
@propertyWrapper
public struct FeatureStatusProperty {
	// MARK: - Dependencies
	
	// Inject FeatureManager dependency
	@Injectable private var featureManager: FeatureManager
	
	// MARK: - Properties
	
	/// The key used for fetching the value from the remote feature manager
	public let key: Feature

	/// Value which will be used if we fail to retrieve a value from the remote feature manager
	public let defaultStatus: FeatureStatus

	public var wrappedValue: FeatureStatus {
		// Create a status from the current remote value
		return featureManager.getTreatment( for: key, attributes: [:] ) ?? defaultStatus
	}

	public init( key: Feature, defaultStatus: FeatureStatus ) {
		self.key = key
		self.defaultStatus = defaultStatus
	}
}

@propertyWrapper
public struct DecodableFeatureConfiguration<T> where T: Decodable {
	// MARK: - Dependencies
	
	// Inject FeatureManager dependency
	@Injectable private var featureManager: FeatureManager
	
	// MARK: - Properties
	
	public let key: String

	/// Used to format the dates found in the configuration.
	private let _strategy: JSONDecoder.DateDecodingStrategy?

	public var wrappedValue: T? {
		// Create a status from the current remote value
		return featureManager.getConfiguration( for: key, dateDecodingStrategy: _strategy )
	}

	public init( key: String, dateDecodingFormatter: DateFormatter? = nil ) {
		self.key = key
		self._strategy = dateDecodingFormatter.map { .formatted( $0 ) } 
	}
}
