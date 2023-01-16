//
//  KeyedDecodingContainer-Extensions.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 30/06/2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer where K == AnyKey {
	/**
	Attempt to get a value for any of the given keys. If no value is found a `keyNotFound` exception is thrown.
	*/
	func decode<T>( keys: [CodingKey]) throws -> T where T: Decodable {
		for key in keys {
			if let value = try? decode(T.self, forKey: AnyKey(stringValue: key.stringValue)) {
				  return value
			  }
		  }

		throw DecodingError.keyNotFound( AnyKey(stringValue: keys.first?.stringValue ?? "Unknown key"), DecodingError.Context(codingPath: keys.map{ AnyKey( stringValue: $0.stringValue )}, debugDescription: "Could not find any of the specified keys"))
	 }

	/**
	Attempt to get a value for any of the given keys, if no value is found `null` is returned
	*/
	func decodeIfPresent<T>( keys: [CodingKey]) -> T? where T: Decodable {
		for key in keys {
			if let value = try? decode(T.self, forKey: AnyKey(stringValue: key.stringValue)) {
				  return value
			  }
		  }

		return nil
	 }
}

/**
A `CodingKey` implementation which allows us to decode a container without specifying all the keys in advance.
*/
struct AnyKey: CodingKey {
	var stringValue: String
	var intValue: Int?
	init(stringValue: String) {
		self.stringValue = stringValue
	}

	init?(intValue: Int) {
		self.stringValue = String(intValue)
		self.intValue = intValue
	}
}
