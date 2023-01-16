//
//  UIScreen-Extensions.swift
//  CoreUserInterface
//
//  Created by Georgi Damyanov on 26/05/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit

public extension UIScreen {
	private struct Constants {
		static let iPhone4SHeight: CGFloat = 480
		static let smallScreenWidth: CGFloat = 320
		static let largeScreenWidth: CGFloat = 414
		static let iPhone6ScreenHeight: CGFloat = 667
	}

	/**
	Check if we are currently running on iPhone 4S
	*/
	static func isSmallestScreen() -> Bool {
		return UIScreen.main.bounds.height == Constants.iPhone4SHeight
	}

	/**
	Check if we are currently running on iPhone 4 or iPhone 5 screen size
	*/
	static func isSmallScreen() -> Bool {
		return UIScreen.main.bounds.width == Constants.smallScreenWidth
	}

	/**
	Check if we are currently running on a Plus screen size
	*/
	static func isLargeScreen() -> Bool {
		return UIScreen.main.bounds.width == Constants.largeScreenWidth
	}

	/// Check if the device is taller than an iPhone 6
	static func isTallScreen() -> Bool {
		return UIScreen.main.bounds.height > Constants.iPhone6ScreenHeight
	}
}
