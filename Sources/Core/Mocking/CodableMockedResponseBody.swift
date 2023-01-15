//
//  CodableMockedResponseBody.swift
//  CoopCore
//
//  Created by Valeriy Kolodiy on 10.03.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public struct CodableMockedResponseBody<T: Codable>: MockedResponseBody {

	public let bodyData: Data?

	public init(codableData: T, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil) {
		let encoder = JSONEncoder()
		dateEncodingStrategy.flatMap { encoder.dateEncodingStrategy = $0 }
		bodyData = try? encoder.encode(codableData)
	}
	
}
