//
//  URL-DeepLinks.swift
//  CoopCore
//
//  Created by Valeriy Kolodiy on 27.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public extension URL {

	/// Transforms the Universal Link URL to regular deep-link URL with a custom scheme.
	/// - Returns: A regular deep-link URL with a provided custom URL scheme.
	/// - Parameter scheme: A custom URL scheme that will be used for a regular deep-link.
	func universalToRegularDeepLinkURL(scheme: String) -> URL? {
		// Get all path components without slashes.
		let pathComponents = pathComponents.filter { $0 != "/" }

		// Retrieve the first path component that serves as a domain in the regular deep-link.
		guard let firstPathComponent = pathComponents.first, !firstPathComponent.isEmpty else {
			// Deeplink should contain at least 1 path component, otherwise it won't be possible to set domain.
			return nil
		}

		// Assemble a regular deep-link url.
		var deepLinkURLComponents = URLComponents()
		deepLinkURLComponents.scheme = scheme
		deepLinkURLComponents.host = firstPathComponent

		// Set query, if present. Important to use `percentEncodedQuery` parameter of
		// `URLComponents` since the query string gets encoded when URL object is initialized.
		if let query = query, !query.isEmpty() {
			deepLinkURLComponents.percentEncodedQuery = query
		}

		// Set remaining `path` components, if present.
		let remainingPath = pathComponents
			.dropFirst()
			.reduce("") { $0 + "/" + $1 }

		if !remainingPath.isEmpty {
			deepLinkURLComponents.path = remainingPath
		}

		return deepLinkURLComponents.url
	}

}
