//
//  Amount.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 29.09.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public struct Amount: Decodable {
	public let currency: String
	public let value: Double
	
	public init( currency: String, value: Double ) {
		self.currency = currency
		self.value = value
	}
}
