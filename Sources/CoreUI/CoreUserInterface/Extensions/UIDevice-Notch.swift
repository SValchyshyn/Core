//
//  UIDevice-Notch.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 21/12/2018.
//  Copyright © 2018 Greener Pastures. All rights reserved.
//

import UIKit

public extension UIDevice {
	struct Constants {
		/// The scren width for iPhone 5 and iPhone 4 screen sizes
		public static let narrowScreenDeviceWidth: CGFloat = 320.0

		/// The height that an iPhone X/ Xs has. iPhone XR/ iPhone XS Max height = 896.0
		public static let notchDeviceMinimumViewHeight: CGFloat = 812.0

		/// The top inset that the SafeArea has on iPhone X/ Xs/ Xr/ Xs Max. (20.0 = status bar height + 24.0 notch height)
		public static let notchDeviceSafeAreaTopInset: CGFloat = 44.0

		/// The top inset that the SafeArea has on any other device. (20.0 = status bar height)
		public static let otherDeviceSafeAreaTopInset: CGFloat = 20.0
	}

	/// Based on the screen size, determines wether it's not an iPhone X or not.
	static let hasNotch = UIScreen.main.bounds.height >= Constants.notchDeviceMinimumViewHeight

	/// Returns the safeArea top inset based on the current device.
	static let safeAreaTopInset = hasNotch ? Constants.notchDeviceSafeAreaTopInset : Constants.otherDeviceSafeAreaTopInset

	/// Based on the screen size, determines whether this is an iPhone 5 or iPhone 4 screen sized device
	static let isNarrowScreen = UIScreen.main.bounds.width == Constants.narrowScreenDeviceWidth
}
