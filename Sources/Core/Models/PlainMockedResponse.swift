//
//  PlainMockedResponse.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 29/04/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

struct PlainMockedResponse: MockedResponse {
	let displayName: String
	let regex: String
	let body: MockedResponseBody?
}
