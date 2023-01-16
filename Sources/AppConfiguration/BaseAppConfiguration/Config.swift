//
//  Config.swift
//  CoopCore
//
//  Created by Marian Hunchak on 24.09.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import CoreNetworking

/**
The part of the data format that is shared between all apps (for now, this could become redundant).
*/
public struct ConfigurationData<T: AppConfigurationProviding>: Codable {
	enum CodingKeys: String, CodingKey {
		case config = "data"
	}
	
	var config: T
}

/**
The minimum requirements for the type containing the data format of the configuration file
*/
public protocol AppConfigurationProviding: Codable {
	associatedtype EndpointType: AppConfigEndpointRepresentation
	
	/// Name of the file, without `extension`, that contains the `RemoteConfig` local data.
	static var configFileName: String { get }
	
	/// The extension of the `configFileName` file.
	static var configFileExtension: String { get }
		
	/// Mapping between "features" and their basic `endpoint` information.
	var endpoints: [String: EndpointType] { get }
	
	/// Allows the customization of the `configuration`.
	/// - Parameters:
	///   - value: New custom information.
	///   - key: The key under which the `value` should be placed.
	mutating func setAppSpecificConfig(_ value: Data?, forKey key: String)
}

public extension AppConfigurationProviding {
	
	/// Default to plist since `AppConfig` uses `PropertyListEncoder` and `PropertyListDecoder`. To be implemented when we make the encoding/ decoding dynamic as well.
	static var configFileExtension: String { "plist" }
	
	/// Convenience variable that combines `configFileName` and `configFileExtension`.
	static var configFullFileName: String { "\(configFileName).\(configFileExtension)" }
}

public protocol AppConfigEndpointRepresentation: Codable {
	
	/// Identifies a suite of endpoints. It's specialized by adding a custom `path` for each endpoint.
	var baseUrl: String { get }
	
	/// Custom timeout period, in `milliseconds`, for `GET` operations.
	/// Do not use directly, go through the `timeout(for:)` method instead which computes the interval in `seconds`.
	var readTimeout: TimeInterval? { get }
	
	/// Custom timeout period, in `milliseconds`, for `POST, PUT and other write` operations.
	/// Do not use directly, go through the `timeout(for:)` method instead which computes the interval in `seconds`.
	var writeTimeout: TimeInterval? { get }
}

public enum AppConfigEndpointConstants {
	
	/// Default `timeout` value for the `read` operations. Should be used when `readTimeout` is `nil`.
	/// Value is in `milliseconds` to align with the time unit from `remote config`.
	static let defaultReadTimeout: TimeInterval = 10_000
	
	/// Default `timeout` value for the `write` operations. Should be used when `writeTimeout` is `nil`.
	/// Value is in `milliseconds` to align with the time unit from `remote config`.
	static let defaultWriteTimeout: TimeInterval = 10_000
}

public extension AppConfigEndpointRepresentation {
	
	/// Provides the `timeout` period, `in seconds`, for a certain endpoint.
	/// - Parameter httpMethod: Helps determine whether the action is `read` or `write`.
	func timeout( for httpMethod: HTTPMethod ) -> TimeInterval {
		let timeout: TimeInterval
		switch httpMethod {
		case .GET, .HEAD:
			timeout = readTimeout ?? AppConfigEndpointConstants.defaultReadTimeout
			
		case .PUT, .PATCH, .DELETE, .POST:
			timeout = writeTimeout ?? AppConfigEndpointConstants.defaultWriteTimeout
		}
		
		// The timeout is in milliseconds, make sure to transform it in seconds.
		return timeout / 1000
	}
}
