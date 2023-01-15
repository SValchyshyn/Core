//
//  WKWebView-Extensions.swift
//  Tracking
//
//  Created by Coruț Fabrizio on 31/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import WebKit

public extension WKWebView {
	/**
	Loads the provided request but, if possible, with the tracking variables appended to the URL

	- parameter request:	The request we want to load with tracking included
	*/
	func loadWithTracking( _ request: URLRequest ) {
		// Make sure we have a valid URL.
		guard let url = request.url else { return }

		Tracking.shared.appendTrackingToURL( url: url ) { trackingURL in
			DispatchQueue.main.async {
				// Keep the original request but swap url with tracking enriched one
				var trackingRequest = request
				trackingRequest.url = trackingURL

				self.load( trackingRequest )
			}
		}
	}

	/**
	Loads the provided data but, if possible, with the tracking variables appended to the URL

	- parameter data:				The data we want to load in the web view
	- parameter mimeType:			The mimetype for the data
	- parameter encodingName:		The encodingIdentifier for the data
	- parameter baseURL:			The URL to which we want to append the tracking variables
	*/
	func loadWithTracking( data: Data, mimeType: String, encodingName: String, baseURL: URL ) {
		Tracking.shared.appendTrackingToURL( url: baseURL ) { trackingURL in
			DispatchQueue.main.async {
				self.load( data, mimeType: mimeType, characterEncodingName: encodingName, baseURL: trackingURL )
			}
		}
	}
}
