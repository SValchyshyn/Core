//
//  MockResponseProvider.swift
//  CoopM16
//
//  Created by Christian Sjøgreen on 18/09/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

public class MockResponseProvider {
	public static let shared = MockResponseProvider()

	/// Indicates whether the response mocking is enabled. Mocking is always disabled for the `App Store` configuration.
	public static var isMockingEnabled: Bool {
		// Verify if the current configuration is not `App Store`.
		guard CoreConfiguration.currentReleaseType != .appStore else { return false }

		// Verify if the response mocking feature is enabled.
		let featureManager: FeatureManager = ServiceLocator.inject()
		let mockDataFeature = featureManager.getTreatment(for: CoreFeatures.mockData, attributes: [:])
		return mockDataFeature == .enabled
	}
	
	/// List of available mock responses.
	private var availableMocks: [ MockedResponse ] = [
		PlainMockedResponse(
			displayName: "Newsfeed",
			regex: "GET /memberapi/v1.1/members/[0-9]*/feeds .*",
			body: BundleFile( name: "newsfeed", ext: "json" )
		),
		PlainMockedResponse(
			displayName: "Vouchers",
			regex: "GET /voucherapi/v2/members/[0-9]+/vouchers/available .*",
			body: BundleFile( name: "vouchers", ext: "json" )
		),
		PlainMockedResponse(
			displayName: "Account Bonus",
			regex: "GET /memberapi/v1.1/members/[0-9]+/bonus/statements .*page=1.*",
			body: BundleFile( name: "account_bonus", ext: "json" )
		),
		PlainMockedResponse(
			displayName: "StoresOnMap",
			regex: "POST /storeapi/v1/stores/shopformap .*",
			body: BundleFile( name: "storesOnMap", ext: "json" )
		),
		PlainMockedResponse(
			displayName: "Account Bonus",
			regex: "GET /memberapi/v1.1/members/[0-9]+/bonus/report ",
			body: BundleFile( name: "bonus_reports", ext: "json" )
		),
		PlainMockedResponse(
			displayName: "Local Offers",
			regex: "GET /marketingapi/v1.1/marketing/localofferandnews/[0-9]+ ",
			body: BundleFile( name: "local_offers", ext: "json" )
		),
		PlainMockedResponse(
			displayName: "AppKup Campaigns",
			regex: "GET /marketingapi/v1.1/marketing/appkup ",
			body: BundleFile( name: "appkup_campaign", ext: "json" )
		),
		PlainMockedResponse(
			displayName: "Campaign Offers",
			regex: "GET /memberapi/v1.1/members/[0-9]+/personaloffers offerTypes=appkupoffer",
			body: BundleFile( name: "campaign_offers", ext: "json" )
		),
		PlainMockedResponse(
			displayName: "Personal Offers",
			regex: "GET /memberapi/v1.1/members/[0-9]+/personaloffers ",
			body: BundleFile( name: "personal_offers", ext: "json" )
		),
		PlainMockedResponse(
			displayName: "Member Offers",
			regex: "GET /marketingapi/v1.1/marketing/memberoffers .*",
			body: BundleFile( name: "member_offers", ext: "json" )
		),
		PlainMockedResponse(
			displayName: "Brand Order",
			regex: "GET /customerinsights/v1/api/CustomerPreferences/retail-groups ",
			body: BundleFile( name: "retail_group_order", ext: "json" )
		)
	]
	
	/**
	Makes sure to take the `response` into consideration when mocking.

	- parameter response:		Used to identify the response.
	*/
	public func registerMock( response: MockedResponse ) {
		availableMocks.append( response )
	}

	/// Returns a mocked response and body for the provided request if supported by this provider.
	public func mockResponse( for request: URLRequest ) -> ( response: HTTPURLResponse, body: Data )? {
		// Ensure that request has a URL.
		guard let requestURL = request.url else {
			return nil
		}
		
		// Define a simple response that can be used for all mocked responses (for now).
		let simpleResponse = HTTPURLResponse(
			url: requestURL,
			statusCode: 200,
			httpVersion: "HTTP/1.1",
			headerFields: nil
		)!
		
		// Check if a mocked body is available for this request.
		guard let mockedBody = mockResponseBody( for: request ) else {
			return nil
		}
		
		// Return mocked response and body.
		return ( response: simpleResponse, body: mockedBody )
	}
	
	/// Returns a body for the provided request if supported by this provider.
	private func mockResponseBody( for request: URLRequest ) -> Data? {
		// Prepare string representation of the request.
		let requestValue = request.matchValue
		
		// Iterate over all available mocks.
		for mock in availableMocks {
			// Check if request matches the mock's regex pattern.
			if requestValue.isMatching( regexPattern: mock.regex ), let data = mock.body?.bodyData {
				print( "Mocked \(mock.displayName) returned for request: \(requestValue) for \(request)" )
				// Return the mocked body file content.
				return data
			}
		}
		
		// No mock available for this request. Return nothing.
		return nil
	}
}

public extension String {
	/// Extension. Returns true only if this String matches the provided regex pattern exactly.
	func isMatching( regexPattern: String ) -> Bool {
		guard let matchRange = range( of: regexPattern, options: .regularExpression ) else {
			return false
		}
		
		// Check that start and end indices cover the entire string.
		return matchRange.lowerBound == startIndex && matchRange.upperBound == endIndex
	}
}

public extension URLRequest {
	/// Extension.
	/// Returns a String that can be used for pattern matching the requests HTTP method and URL path.
	/// Format: "METHOD PATH"
	var matchValue: String {
		let method: String = httpMethod ?? ""
		let path = url?.path ?? ""
		let query = url?.query ?? ""
		return "\(method) \(path) \(query)"
	}
}
