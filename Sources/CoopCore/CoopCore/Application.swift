//
//  Application.swift
//  CoopM16
//
//  Created by Marius Constantinescu on 12/02/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

/// A structure that gives you easier access to the app's bundle info
public struct Application {
	private static func string(for key: String) -> String? {
		return Bundle.main.infoDictionary?[ key ] as? String
	}

	private static var deviceName: String {
		return UIDevice.current.modelName
	}

	private static var osVersion: String {
		return UIDevice.current.systemVersion
	}

	/// The push token
	public static var nativePushToken: String? {
		return StartupManager.RequestPushNotificationOperation.currentPushNotificationTokenString()
	}

	/// The application's name. CFBundleDisplayName if there, otherwise CFBundleName
	public static var appName: String? {
		return Application.string(for: "CFBundleDisplayName") ?? Application.string(for: "CFBundleName")
	}

	/// App version number. CFBundleShortVersionString
	public static var appVersion: String? {
		return Application.string(for: "CFBundleShortVersionString")
	}

	/// App build number. CFBundleVersion
	public static var appBuildNumber: String? {
		return Application.string(for: "CFBundleVersion")
	}

	/// App bundle id. CFBundleIdentifier
	public static var appBundleId: String? {
		return Application.string(for: "CFBundleIdentifier")
	}

	/** Produces a String with a payload used for debug
	```
	deviceName: iPhone11,8
	osVersion: 12.1.4
	nativePushToken: 9E0F2CFE1E958DFC3EAF2B21E18139FEA1508BF8F8D36332E75D83527135A25A
	appName: Coop α
	appVersion: 18.9
	appBuildNumber: 21
	appBundleId: dk.greenerpastures.coopm16
	```
	*/
	public static var debugInfo: String {
		return """
		deviceName: \(deviceName)
		osVersion: \(osVersion)
		nativePushToken: \(nativePushToken.emptyIfNil)
		appName: \(appName.emptyIfNil)
		appVersion: \(appVersion.emptyIfNil)
		appBuildNumber: \(appBuildNumber.emptyIfNil)
		appBundleId: \(appBundleId.emptyIfNil)
		"""
	}
}

private extension Optional where Wrapped == String {
	var emptyIfNil: String {
		return self ?? ""
	}
}
