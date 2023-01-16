//
//  PriceConfiguration.swift
//  CoreUserInterface
//
//  Created by Marian Hunchak on 20.08.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

/// Determines how the `decimals` should be sized relative to the `amount`.
public enum DecimalType {
	/// A `1:1` font size ratio will be kept.
	case normal
	
	/// A `3:5` font size ratio will be used.
	case small
}

public protocol PriceConfiguration {
	var fontSize: CGFloat { get set }
	var symbol: String { get set }
	var decimalType: DecimalType { get set }
}
