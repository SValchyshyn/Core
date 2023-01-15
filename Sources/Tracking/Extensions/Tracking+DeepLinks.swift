//
//  Tracking+DeepLinks.swift
//  Tracking
//
//  Created by Valeriy Kolodiy on 17.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Core

public extension Tracking {

	private enum Events {
		static let deepLinkClick = "deeplink-click"
	}

	private enum EventsKeys {
		static let campaignID = "cid"
		static let deepLink = "deep_link"
	}

	private enum URLParameters {
		static let campaignID = "cid"
		static let campaignTrackingCode = "a.launch.campaign.trackingcode"
	}

	/// Tracks the deep-link event if either the `cid` or `a.launch.campaign.trackingcode` parameters are present in the deep-link URL.
	/// - Parameter url: A deep-link URL.
	func trackDeepLinkIfNeeded(with url: URL) {
		// Make sure the URL is valid and contains query items.
		guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
			  let queryItems = urlComponents.queryItems else { return }

		// Check for the `campaignID` parameter first, then fallback to `campaignTrackingCode`, if present.
		// Deep-link tracking should be skipped if both parameters are missing.
		guard let campaignID = queryItems[URLParameters.campaignID] ?? queryItems[URLParameters.campaignTrackingCode] else { return }

		let eventParameters = [EventsKeys.deepLink: url.absoluteString,
							   EventsKeys.campaignID: campaignID]

		Tracking.shared.trackEvent(event: Events.deepLinkClick,
								   parameters: eventParameters,
								   includeExtraInfo: true)
	}

}
