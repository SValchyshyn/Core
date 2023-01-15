//
//  TrackingURLProvider.swift
//  Tracking
//
//  Created by Stepan Valchyshyn on 01.07.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

/// Manager to enchance web URL with tracking parameters
public protocol TrackingURLProvider {
	/**
	Returns a URL with appended tracking variables to the provided URL

	- parameter url: 	The URL to which we want to append the tracking variables
	*/
	func appendTrackingToURL( url: URL, completion: @escaping (_ url: URL ) -> Void )
}
