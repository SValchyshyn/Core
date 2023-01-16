//
//  Theme.swift
//  CoreUserInterface
//
//  Created by Roman Croitor on 27.09.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers
import Core

public class Theme {
	
	public struct Colors {
		public static let darkGray = UIColor( hex: 0x333333 )        // RGB: 51, 51, 51
		public static let gray = UIColor( hex: 0xCCCCCC )			 // RGB: 204, 204, 204
		public static let lightGray = UIColor( hex: 0x8A898A )        // RGB: 138, 137, 138
		public static let moreMenuItemBorder = UIColor( hex: 0xE5E5E5 ) // RGB: 229, 229, 229
	}

	public struct Shadow {
		public static let color = Colors.darkGray.cgColor
		public static let radius: CGFloat = 3
		public static let opacity: Float = 0.3
		public static let offset: CGSize = CGSize( width: 0, height: 2 )
	}

	public struct Durations {
		/// Duration of the fade in when showing cells' images
		public static let cellImagesFadeInDuration: TimeInterval = 0.2

		/// Default animation duration
		public static let standardAnimationDuration: TimeInterval = 0.3
	}

	public struct CellDimensions {
		/// Corner radius for front page cells
		public static let feedItemCornerRadius: CGFloat = 15

		/// Corner radius for food inspiration cells
		public static let foodInspirationCornerRadius: CGFloat = 5
	}

	public struct PhoneAnimationScaleFactor {
		public static let iPhone4: CGFloat = 0.55
		public static let iPhone5: CGFloat = 0.75
	}

	/// Initializes UI appearance.
	/// Call this method from `application:didFinishLaunchingWithOptions` once the `Colors` and the `Fonts` have been injected.
	public class func setAppearance() {
		let colors: ColorsProtocol = ServiceLocator.inject()
		let fonts: PlatformFontProvider = ServiceLocator.inject()
		let normalTabBarAttributes: [NSAttributedString.Key: Any] = [
			.font: fonts.tabBarFont,
			.foregroundColor: colors.bodyTextColor
		]
		var selectedTabBarAttributes: [NSAttributedString.Key: Any] = [
			.font: fonts.tabBarFont,
			.foregroundColor: colors.primaryColor
		]
		let navBarAttributes: [NSAttributedString.Key: Any] = [
			.font: fonts.H5HeaderFont,
			.foregroundColor: colors.colorSurface
		]
		
		let tabBarAppearance = UITabBarAppearance()
		let tabBarItemAppearance = UITabBarItemAppearance()
		// Unselected.
		tabBarItemAppearance.normal.iconColor = normalTabBarAttributes[.foregroundColor] as? UIColor // use the same color as we do for the title.
		tabBarItemAppearance.normal.titleTextAttributes = normalTabBarAttributes
		// Selected.
		selectedTabBarAttributes[.foregroundColor] = tabBarItemAppearance.selected.iconColor // use the same color as we do for the icon.
		tabBarItemAppearance.selected.titleTextAttributes = selectedTabBarAttributes
		
		tabBarAppearance.backgroundColor = colors.colorSurface
		tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
		
		UITabBar.appearance().standardAppearance = tabBarAppearance
		
		if #available(iOS 15, *) {
			// In iOS 15, UIKit has extended the usage of the scrollEdgeAppearance, which by default produces a transparent background to all navigation bars.
			// We want to restore the old look by setting the appearance for `.scrollEdgeAppearance`
			UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
			
			let navBarAppearance = UINavigationBarAppearance()
			navBarAppearance.configureWithOpaqueBackground()
			navBarAppearance.backgroundColor = colors.primaryColor
			navBarAppearance.titleTextAttributes = navBarAttributes
			UINavigationBar.appearance().standardAppearance = navBarAppearance
			UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
		} else if #available(iOS 13, *) {
			// Navigation bar
			UINavigationBar.appearance().barTintColor = colors.primaryColor
			UINavigationBar.appearance().isTranslucent = false
			UINavigationBar.appearance().tintColor = colors.colorSurface
			UINavigationBar.appearance().titleTextAttributes = navBarAttributes
		}
	}
}
