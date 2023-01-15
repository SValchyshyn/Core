//
//  Config.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 08/11/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

/**
Configuration variables on which the Core module depends
*/
public struct CoreConfiguration {
	/**
	Keys for accessing configuration values from the `Info.plist` file.
	*/
	private enum InfoPlist: String, InfoPlistKey {
		case displayName = "DISPLAY_NAME"
		case configName = "CONFIGURATION_NAME"
		case authorizationServerURL = "AUTHORIZATION_SERVER_URL"
		case lowSecurityClientID = "LOW_SECURITY_CLIENT_ID"
		case highSecurityClientId = "HIGH_SECURITY_CLIENT_ID"
		case apiServerHostName = "API_SERVER_HOST_NAME"
		case appConfigBaseURL = "APP_CONFIG_BASE_URL"
		case appConfigDefaultFileName = "APP_CONFIG_DEFAULT_FILE_NAME"
		case releaseType = "RELEASE_TYPE"
		case splitAPIKey = "SPLIT_API_KEY"
		case businessUnitName = "BUSINESS_UNIT_NAME"
		case mobilePayV2UrlSchema = "MOBILE_PAY_V2_URL_SCHEMA"
		case remoteLoggingApplication = "REMOTE_LOGGING_APPLICATION"
		case quickInfoHostName = "QUICK_INFO_HOST_NAME"
		case deviceBindingReturnURL = "DEVICE_BINDING_RETURN_URL"
		case energyURL = "ENERGY_URL"
		case insuranceURL = "INSURANCE_URL"
		case quickCoopHostName = "QUICKCOOP_HOST_NAME"
		case freemiumSignupURL = "FREEMIUM_SIGNUP_URL"
		case trackingName = "TRACKING_NAME"
		case mobilepayMerchantUrlScheme = "MOBILEPAY_MERCHANT_URL"
		case developmentTeam = "DEVELOPMENT_TEAM"
	}

	public static let displayName: String = InfoPlist.displayName.value()
	
	public static let appInfo: AppInfo = ServiceLocator.inject()
	
	public static var current: Configuration = InfoPlist.configName.value()
	
	/// App name used for analytics.
	public static let businessUnitName: String = InfoPlist.businessUnitName.value()
	
	/// MobilePay app redirect URL scheme
	public static let mobilepayMerchantUrlScheme: String = InfoPlist.mobilepayMerchantUrlScheme.value()
	
	/// MobilePay V2 url schema
	public static let mobilePayV2UrlSchema: String = InfoPlist.mobilePayV2UrlSchema.value() + "://"
	
	/// App name used for RemoteLogging.
	public static let remoteLoggingApplication: String = InfoPlist.remoteLoggingApplication.value()
	
	/// App name used for tracking.
	public static let trackingApplication: String = InfoPlist.trackingName.value()

	// The current release type. Unlike the configuration which can have a production setup for enterprise builds this returns explicitly the release type; Debug, Eneterprise or App Store
	public static var currentReleaseType: ReleaseType = InfoPlist.releaseType.value()

	/// API server host name for OAuth2 authorization server.
	public static var authorizationServerURL: URL = InfoPlist.authorizationServerURL.value()

	/// Client ID used for low security API requests.
	public static var lowSecurityClientID: String = InfoPlist.lowSecurityClientID.value()

	/// Client ID used for high security API requests.
	public static var highSecurityClientID: String = InfoPlist.highSecurityClientId.value()
	
	/// Filename of default AppConfig values file that the app is shipped with
	public static var appConfigDefaultFileName: String = InfoPlist.appConfigDefaultFileName.value()
	
	/// Development team ID.
	public static let developmentTeam: String = InfoPlist.developmentTeam.value()

	public enum APISubscriptionKeys {
		/// API key used with the Split.io client.
		public static let splitAPIKey: String = InfoPlist.splitAPIKey.value()
	}

	public enum URLs {
		/// Host for the API server.
		public static let apiServerHostName: String = InfoPlist.apiServerHostName.value()
		
		/// Quick Info host URL
		public static let quickInfoHostUrl: String = "https://" + InfoPlist.quickInfoHostName.value()
		
		/// AppConfig API URL
		public static let appConfigBaseURL: String = InfoPlist.appConfigBaseURL.value()

		/// Return URL to be passed to the device binding authorize endpoint (NB: this is a String, not a URL since it's a value we're passing to another endpoint)
		public static let deviceBindingReturnURLString: String = InfoPlist.deviceBindingReturnURL.value()
		
		/// Energy page URL
		public static let energyURL: URL = InfoPlist.energyURL.value()
		
		/// Insurance page URL
		public static let insuranceURL: URL = InfoPlist.insuranceURL.value()
		
		/// QuickCoop host URL
		public static let quickCoopURL: URL = InfoPlist.quickCoopHostName.value()
		
		/// Freemium Signup URL
		public static let freemiumSignupURL: URL = InfoPlist.freemiumSignupURL.value()
	}

	/**
	These are the values used as configuration names in Info.plist.
	*/
	public enum Configuration: String {
		case debug = "Debug"
		case enterprise = "Enterprise"
		case production = "Production"
	}

	/**
	These are the values used as release types in the configuration files.
	*/
	public enum ReleaseType: String {
		case debug = "Debug"
		case enterprise = "Enterprise"
		case appStore = "AppStore"
	}
}

/// Application specific information.
public protocol AppInfo {
	
	/// Unique identifier of the country to which the `LoyaltyScheme` should adhere to.
	var countryIdentifier: String { get }

	/// Unique identifier, non ISO compliant of the language.
	var languageIdentifier: String { get }
}
