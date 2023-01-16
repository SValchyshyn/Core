//
//  UIColor+Hex.swift
//  CoreUserInterface
//
//  Created by Jens Willy Johannsen on 17/11/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

import UIKit

public extension UIColor {
	/**
	Returns a UIColor based on hex RGB values.

	:param: hex The RGB color as a hex integer – e.g. 0xf7f7f7
	:returns: An initialized UIColor object.
	*/
	convenience init(hex hexInt: Int) {
		let red = CGFloat(hexInt >> 16) / CGFloat(255)
		let green = CGFloat((hexInt >> 8) & 0xFF) / CGFloat(255)
		let blue = CGFloat(hexInt & 0xFF) / CGFloat(255)
		self.init(red: red, green: green, blue: blue, alpha: 1)
	}

	/**
	Returns a UIColor based on RGB values from 0-255 instead of 0-1.

	:param: red Red value as an integer from 0 to 255.
	:param: green Green value as an integer from 0 to 255.
	:param: blue Blue value as an integer from 0 to 255.
	:param: alpha Opacity from 0 to 1. Defaults to 1.0
	:returns: An initialized UIColor object.
	*/
	convenience init(red: Int, green: Int, blue: Int, alpha: Float = 1) {
		let red = CGFloat(red) / CGFloat(255)
		let green = CGFloat(green) / CGFloat(255)
		let blue = CGFloat(blue) / CGFloat(255)
		self.init(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
	}
}
