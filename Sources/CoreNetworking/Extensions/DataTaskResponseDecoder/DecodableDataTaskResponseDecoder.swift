//
//  DecodableDataTaskResponseDecoder.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 18.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Log
import Core

/// Decodes response data into decodable value.
struct DecodableDataTaskResponseDecoder<T: Decodable>: DataTaskResponseDecoder {
	
	let request: URLRequest
	let errorIdentifier: String
	let jsonDecoder: JSONDecoder
	
	func decode(data: Data) throws -> T {
		do {
			var data = data

			// Use empty JSON data instead of empty data, because JSONDecoder treats this case as DecodingError.dataCorrupted. Empty response body is used in PrimeAPI. -SV
			if data.isEmpty, let emptyJsonData = try? JSONSerialization.data(withJSONObject: []) {
				data = emptyJsonData
			}

			return try jsonDecoder.decode(T.self, from: data)
		} catch let DecodingError.keyNotFound(_, context) {
			// The key/value is missing from the payload
			Log.technical.log(.error, "Decoding error: could not decode server response to data model object due to missing key for '\(context.codingPath.objectPath)' on \(T.self). Context: \(context.debugDescription)", [.identifier(errorIdentifier + ".6"), .urlRequest(request)])
		} catch let DecodingError.valueNotFound(_, context) {
			// A nil value was found when we expected a non-optional value
			Log.technical.log(.error, "Decoding error: could not decode server response to data model object due to a nil value for non-optional property '\(context.codingPath.objectPath)' on \(T.self). Context: \(context.debugDescription)", [.identifier(errorIdentifier + ".7"), .urlRequest(request)])
		} catch let DecodingError.typeMismatch(_, context) {
			// A type mismatch between JSON payload and the model's property type
			Log.technical.log(.error, "Decoding error: could not decode server response to data model object due to type mismatch for property '\(context.codingPath.objectPath)' on \(T.self). Context: \(context.debugDescription)", [.identifier(errorIdentifier + ".8"), .urlRequest(request)])
		} catch {
			Log.technical.log(.error, "Could not decode server response to data model object: \(error).", [.identifier(errorIdentifier + ".5"), .urlRequest(request)])
		}
		
		throw APIError.invalidResponse
	}
	
}

private extension Array where Element == CodingKey {
	
	var objectPath: String {
		map { $0.stringValue }.joined(separator: ".")
	}
	
}
