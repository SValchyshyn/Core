//
//  AmountUI.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 24.07.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Core

/// UI layer model wrapper over Amount data
public struct AmountUI {
	public let currency: Currency
	public let value: Double
	
	public init( currency: Currency, value: Double ) {
		self.currency = currency
		self.value = value
	}
}

extension Amount {
	public func toAmountUI() -> AmountUI {
		let currencyProvider: CurrencyProvider = ServiceLocator.inject()
		return AmountUI(currency: currencyProvider.getCurrency(), value: value)
	}
}
