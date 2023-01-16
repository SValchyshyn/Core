//
//  SafelyDecodable.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 23/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// Wrapper for safely decoding a value without throwing an exception
public struct SafelyDecodable<T: Decodable>: Decodable {
	public let result: Result<T, Error>

	public init( from decoder: Decoder ) throws {
		result = Result( catching: { try T( from: decoder )})
	}
}
