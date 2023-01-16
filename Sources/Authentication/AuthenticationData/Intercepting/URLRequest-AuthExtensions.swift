//
//  URLRequest-AuthExtensions.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 09.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import Core
import CoreNetworking
import DefaultAppConfiguration

public extension URLRequest {
	private enum HeaderKeys {
		static let contentType = "Content-Type"
		static let authorization = "Authorization"
		static let acceptLanguage = "Accept-Language"
	}
	
	private enum HeaderValues {
		static let contentType = "application/json"
	}
	
	/**
	Initialize request for API call.

	- parameter endpoint:      					Complete API endpoint with absolute path e.g. 'profile' or 'offers/current'
	- parameter httpMethod:    					HTTP method e.g. 'POST'
	- parameter query:         					Dictionary appended as HTTP query parameters e.g. '?limit=100&page=2'
	- parameter headers:         				Dictionary appended as HTTP headers
	- parameter networkServiceTypeResponsive:	If set to `true`, the `.networkServiceType` will be set to `.responsiveData`. Defaults to `false`. Has no effect on < iOS 12.
	*/
	init( for endpoint: RemoteConfigurableAPIEndpoint, httpMethod: HTTPMethod, query: [String: String]? = nil, headers: [String: String]? = nil, networkServiceTypeResponsive: Bool = false ) throws {
		// Generate URL relative to baseURL
		guard let url = endpoint.completeUrl else {
			throw URLRequestError.noUrlError
		}

		// Add any paramters
		var components = URLComponents( url: url, resolvingAgainstBaseURL: true )!
		components.queryItems = query?.map { URLQueryItem( name: $0.0, value: $0.1 ) }

		// Construct URL
		self.init( url: components.url! )

		// Add the given headers
		headers?.forEach { addValue( $0.value, forHTTPHeaderField: $0.key) }

		// Set HTTP method
		self.httpMethod = httpMethod.rawValue

		// Set NetworkServiceType if specified (iOS 12+ only)
		if #available( iOS 12.0, *), networkServiceTypeResponsive {
			networkServiceType = .responsiveData
		}
		
		addLocalizationHeader()

		// Add content type json for all calls that upload json
		if httpMethod != .GET {
			addValue( HeaderValues.contentType, forHTTPHeaderField: HeaderKeys.contentType )
		}
		
		// Get the specific timeout for the endpoint, if the server does not provide a timeout for this endpoint we default to 10 seconds.
		// If the endpoint is not defined at all on the server side we will get `nil` and the value won't be set, resulting in the default OS value.
		if let timeout = endpoint.timeout( for: httpMethod ) {
			timeoutInterval = timeout
		}
	}
	
	/**
	Initialize request for API call with Codable body.

	- parameter method:        API method with path e.g. 'profile' or 'offers/current'
	- parameter httpMethod:    HTTP method e.g. 'POST'
	- parameter query:         Dictionary appended as HTTP query parameters e.g. '?limit=100&page=2'
	- parameter headers:       Dictionary appended as HTTP headers
	- parameter body:          Encodable object to be encoded as JSON body
	- parameter networkServiceTypeResponsive:	If set to `true`, the `.networkServiceType` will be set to `.responsiveData`. Defaults to `false`. Has no effect on < iOS 12.
	- parameter bodyDateFormatter: Optional date formatter for encoding body Date fields to JSON
	*/
	init<T>( for method: RemoteConfigurableAPIEndpoint, httpMethod: HTTPMethod, query: [String: String]? = nil, headers: [String: String]? = nil, body: T, networkServiceTypeResponsive: Bool = false, bodyDateFormatter: ImmutableDateFormatter? = nil ) throws where T: Encodable {
		try self.init( for: method, httpMethod: httpMethod, query: query, headers: headers, networkServiceTypeResponsive: networkServiceTypeResponsive )

		let encoder = JSONEncoder()
		if let formatter = bodyDateFormatter as? DateFormatter {
			encoder.dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.formatted( formatter )
		}

		httpBody = try? encoder.encode( body )
	}
	
	/// Add `Accept-Language` header taken from `LocaleProvider`
	mutating func addLocalizationHeader() {
		let localeProvider: LocaleProvider = ServiceLocator.inject()
		
		guard let languageCode = localeProvider.appLocale.languageCode else {
			return
		}
		
		addValue( languageCode, forHTTPHeaderField: HeaderKeys.acceptLanguage )
	}
}
