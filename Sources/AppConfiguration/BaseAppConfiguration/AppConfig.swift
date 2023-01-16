//
//  AppConfig.swift
//  AppConfig
//
//  Created by Marian Hunchak on 11.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import CoopCore
import Log
import Foundation

/*/
This is outside of the generic class in order to be easily accessible without providing a concrete type.
*/
public enum AppConfigErrors: Error {
	case missingAPIUrl
}

/**
Interface used to provide access to the bare minimum information we require and endpoint to have, circumventing the generics required in `AppConfig`.
*/
public protocol AppConfigEndpointProvider {
	
	/// Extracts the bare minimum interface out of the specialized `endpoints`.
	/// - Parameter configKey: Used to uniquely identify an `endpoint`.
	func endpoint( for configKey: String ) -> AppConfigEndpointRepresentation?
}

/**
Generic class for accessing the configuration of the given type.
*/
public final class AppConfig<T: AppConfigurationProviding>: AppConfigEndpointProvider {

	public init() {
		internalConfig = AppConfig.getCachedConfig() ?? AppConfig.getDefaultConfig()
	}
	
	// MARK: - 	Properties
	
	public private(set) var config: T {
		get { return queue.sync { internalConfig } }
		set { queue.async(flags: .barrier) { self.internalConfig = newValue } }
	}
	
	/// Queue for synchronized access to internalConfig.
	private let queue = DispatchQueue( label: "appconfig.readwrite.config", attributes: .concurrent )
	
	/// The latest available instance of AppConfiguration. Should never be empty. Taken from API or from local file with default values
	private var internalConfig: T
	private var appConfigAPI = AppConfigAPI()
	
	// MARK: - Methods
	
	public func endpoint( for configKey: String ) -> AppConfigEndpointRepresentation? {
		config.endpoints[ configKey ]
	}

	public func fetchRemoteData() async throws {
		do {
			let config: ConfigurationData<T>? = try await appConfigAPI.getAppConfig()
			
			guard let configData = config?.config else {
				return
			}
			
			self.saveToFile( config: configData )
			self.config = configData
			
		} catch let error {
			Log.technical.log(.error, "Failed to load config with error: \(error)", [.identifier("appConfig.fetchRemoteData")])
			throw error
		}
	}
	
	// MARK: Development
	
	public var baseURL: URL? {
		appConfigAPI.baseUrl
	}
	
	/// Updates base URL with the new one. If url is `nil` then use default one.
	public func setCustomBaseURL(_ url: URL?) {
		appConfigAPI.setCustomBaseURL(url)
	}
	
	// MARK: Remote app config
	
	public var appConfigVersion: String? {
		appConfigAPI.appConfigVersion
	}
	
	public func resetAppConfig() {
		appConfigAPI.resetAppConfigVersion()
		internalConfig = AppConfig.getDefaultConfig()
		try? FileManager.default.removeItem(at: Self.cachedConfigURL)
	}
	
	// MARK: - Private Methods
	
	private func saveToFile( config: T ) {
		let encoder = PropertyListEncoder()
		encoder.outputFormat = .xml

		do {
			let data = try encoder.encode( config )
			try data.write( to: Self.cachedConfigURL )
		} catch {
			NSLog( "Failed to save config with error: \(error)" )
		}
	}
	
	private static var cachedConfigURL: URL {
		let documentsPath = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask )[0]
		return documentsPath.appendingPathComponent( T.configFullFileName )
	}
	
	private static func getCachedConfig() -> T? {
		guard let data = try? Data(contentsOf: cachedConfigURL) else { return nil }
		return try? PropertyListDecoder().decode( T.self, from: data )
	}
	
	private static func getDefaultConfig() -> T {
		var fileURL: URL?
		
		Bundle.allBundles.forEach { bundle in
			guard fileURL == nil else { return }
			fileURL = bundle.url( forResource: T.configFileName, withExtension: T.configFileExtension )
		}
		
		guard let url = fileURL, let fileData = try? Data( contentsOf: url ) else {
			fatalError("AppConfig: Add '\( T.configFullFileName )' file to your target with default configuration!")
		}
		
		do {
			var config = try PropertyListDecoder().decode(T.self, from: fileData)
			
			// parsing app specific config
			if let properties = try? PropertyListSerialization.propertyList(from: fileData, format: nil) as? [String: Any] {
				var configKeysIgnored: [String] = []

				// extracting general config first level keys (available across all apps)
				if let jsonData = try? JSONEncoder().encode(config),
				   let generalConfig = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
					configKeysIgnored.append(contentsOf: generalConfig.keys)
				}

				// loop through all configurations and add them as app specific configuration
				properties.keys.forEach {
					guard !$0.isEmpty else { return }
					guard !configKeysIgnored.contains($0) else { return }

					// store as serialized JSON to replicate fetching from backend
					let propertyData = try? JSONSerialization.data(withJSONObject: properties[$0] as Any)
					config.setAppSpecificConfig(propertyData, forKey: $0)
				}
			}
			
			return config
		} catch {
			fatalError( "AppConfig: Failed parsing default config with error: \(error)" )
		}
	}
}
