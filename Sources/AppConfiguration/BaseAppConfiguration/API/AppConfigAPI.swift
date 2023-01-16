//
//  AppConfigAPI.swift
//  AppConfig
//
//  Created by Marian Hunchak on 11.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import Core
import Log
import UserDefault

final class AppConfigAPI {
	private enum Constants {
		static let configVersionHeaderKey = "If-None-Match"
		static let etagHeaderKey = "Etag"
		static let remoteAppConfigVersion = "remoteAppConfigVersion"
		static let customBaseURLKey = "customBaseURL"
		static let defaultBaseURL = URL( string: "https://\(CoreConfiguration.URLs.appConfigBaseURL)" )
	}
	
	private enum UserSettings {
		/**
		Version of last retrieved app config. If version matches the latest stored on the server - then the API response will have empty body.
		*/
		@UserDefault( key: Constants.remoteAppConfigVersion, defaultValue: nil )
		static var remoteAppConfigVersion: String?
		
		/**
		Cached custom base URL
		*/
		@CodableUserDefault( key: Constants.customBaseURLKey, defaultValue: nil, shouldClearOnLogout: false )
		static var customBaseURL: URL?
	}
	
	// MARK: Base URL
	
	var baseUrl: URL? {
		UserSettings.customBaseURL ?? Constants.defaultBaseURL
	}
	
	/// Updates base URL with the new one. If url is `nil` then use default one.
	func setCustomBaseURL(_ url: URL?) {
		UserSettings.customBaseURL = url
	}
	
	// MARK: Remote app config
	
	var appConfigVersion: String? {
		UserSettings.remoteAppConfigVersion
	}
	
	func resetAppConfigVersion() {
		UserSettings.remoteAppConfigVersion = nil
	}
}

extension AppConfigAPI {
	
	func getAppConfig<T: AppConfigurationProviding>() async throws -> ConfigurationData<T>? {
		let endpoint = AppConfigEndpoint.latestConfig
		
		guard let completeUrl = baseUrl?.appendingPathComponent(endpoint.path) else {
			// Return an error if no URL for endpoint
			throw AppConfigErrors.missingAPIUrl
		}
		
		let headers = [Constants.configVersionHeaderKey: UserSettings.remoteAppConfigVersion ?? ""]
		var request = URLRequest(url: completeUrl)
		request.httpMethod = endpoint.httpMethod.rawValue
		headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
		request.cachePolicy = .reloadIgnoringLocalCacheData
		
		do {
			let task = try await URLSession.core.data(for: request)
			
			guard !task.0.isEmpty else {
				Log.technical.log(.info, "Current app config version is up to date", [.identifier("appConfigAPI.getAppConfig")])
				return nil
			}
			
			if let response = (task.1 as? HTTPURLResponse)?.statusCode, response >= 400 {
				throw APIError.httpStatusError( statusCode: response, errorString: nil, payload: nil )
			}
			
			if let httpResponse = task.1 as? HTTPURLResponse {
				 if let configVersion = httpResponse.allHeaderFields[Constants.etagHeaderKey] as? String {
					// Update current config version
					UserSettings.remoteAppConfigVersion = configVersion
				 }
			}
			
			do {
				var dataModel = try JSONDecoder().decode( ConfigurationData<T>?.self, from: task.0 )
				// Check for nil. We need to do this, because, function use inout parameter
				if dataModel != nil {
					try self.checkForSpecificConfigs(data: task.0, configurationData: &dataModel!)
				}
				
				return dataModel

			} catch let error {
				// JSON conversion failed: Log the error and call completion handler
				Log.technical.log(.error, "Error while parsing AppConfig response: \(error)", [.identifier("appConfigAPI.getAppConfig")])
				throw error
			}
			
		} catch let error {
			Log.technical.log(.error, "Error while getting minimum app version: \(error)", [.identifier("appConfigAPI.getAppConfig")])
			throw error
		}
		
	}
	
	private func checkForSpecificConfigs<T: AppConfigurationProviding>(data: Data, configurationData: inout ConfigurationData<T>) throws {
		if let dataDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any],
		   let appConfigDictionary = dataDictionary[ConfigurationData<T>.CodingKeys.config.rawValue] as? [String: Any] {
			// Create Mirror of config to get exact type of endpoints
			let mirror = Mirror(reflecting: configurationData.config)
			let endpointsType = type(of: configurationData.config.endpoints)
			// Get endpoints variable name, that's in the config
			let endpointsKey = mirror.children.filter{ type(of: $0.value) == endpointsType }.first?.label ?? ""
			// Search for every config, that aren't endpoint one
			try appConfigDictionary.keys.forEach {
				if $0 != endpointsKey, let someAppConfig = appConfigDictionary[$0] {
					let someAppConfigData = try JSONSerialization.data(withJSONObject: someAppConfig)
					// and add it as specific
					configurationData.config.setAppSpecificConfig(someAppConfigData, forKey: $0)
				}
			}
		}
	}
}
