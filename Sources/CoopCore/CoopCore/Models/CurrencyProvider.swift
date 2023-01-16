//
//  CurrencyProvider.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 27.07.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

// Currency localization provider. Provide localization by currency code.
public protocol CurrencyProvider {
	func getCurrency() -> Currency
}

public struct Currency {
	public let code: String
	public let shortForm: String
	
	public init ( code: String, shortForm: String ) {
		self.code = code
		self.shortForm = shortForm
	}
}
