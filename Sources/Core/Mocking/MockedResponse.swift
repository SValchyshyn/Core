//
//  MockedResponse.swift
//  CoopM16
//
//  Created by Christian Sjøgreen on 18/09/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

/// Defines the content of a mocked API response.
public protocol MockedResponse {
	/// Human-readable name of the endpoint/state being mocked.
	var displayName: String { get }
	
	/// Defines a regular expression used to match the mocked URLRequest.
	/// Example: GET /memberapi/v1.1/members/[0-9]*/feeds
	var regex: String { get }
	
	/// The source of the mocked response body.
	var body: MockedResponseBody? { get }
}

public protocol MockedResponseBody {
	var bodyData: Data? { get }
}
