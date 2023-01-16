//
//  Decimal+extensions.swift
//  ScanAndPay
//
//  Created by Olexandr Belozierov on 09.12.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public extension Decimal {
	
	var truncated: Double {
		Double(truncating: self as NSNumber)
	}
	
}
