//
//  TrackingProvider.swift
//  Tracking
//
//  Created by Stepan Valchyshyn on 01.07.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

/// Tracking tool provider protocol to define some common behavior
public protocol TrackingProvider {
	/**
	Configure tracking tool with provided static system info data.

	- parameter systemInfo:		System info data like iOS version, app version, etc.
	*/
	func setup( with systemInfo: [String: String] )
	
	/**
	Notify tracking tool about user authentication state change to configure with the corresponding UUDI

	- parameter authenticationState:	User authentication state
	*/
	func syncTrackingID( for authenticationState: TrackingAuthenticationState )

	/**
	Send the IDFA to the tracking provider
	*/
	func setAdvertisingIdentifier(_ IDFA: String?)
	
	/**
	Performs tracking on the provided category.

	- parameter category:					Identifies between tracking a state or an action.
	- parameter parameters: 				Dictionary with extra parameters.
	- parameter includeExtraInfo:    		`true` to include member info.
	*/
	func track( _ category: TrackingCategory, parameters: [String: String], includeExtraInfo: Bool )
}
