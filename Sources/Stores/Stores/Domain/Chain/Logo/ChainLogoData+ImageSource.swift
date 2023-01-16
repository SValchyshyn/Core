//
//  ChainLogoData+ImageSource.swift
//  Stores
//
//  Created by Oleksandr Belozierov on 09.12.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

extension ChainLogoData {
	
	/// Logo image URL provider.
	public struct ImageSource {
		
		internal let urlProvider: (ChainURLContainer) -> URL?
		
		/// Creates new instance with mapper from`ChainURLContainer` to URL.
		public init(urlProvider: @escaping (ChainURLContainer) -> URL?) {
			self.urlProvider = urlProvider
		}
		
		/// Creates new instance with URL keypath for `ChainURLContainer`.
		public init(keyPath: KeyPath<ChainURLContainer, URL?>) {
			urlProvider = { $0[keyPath: keyPath] }
		}
		
	}
	
}

extension ChainLogoData.ImageSource {
	
	/// Image source for default logo.
	public static var logo: Self {
		Self(keyPath: \.logo)
	}
	
	/// Image source for white logo.
	public static var white: Self {
		Self(keyPath: \.whiteLogo)
	}
	
	/// Image source for alias logo (uses white logo in case alias logo is not available).
	public static var alias: Self {
		Self { $0.aliasLogo ?? $0.whiteLogo }
	}
	
	/// Image source for pin logo.
	public static var pin: Self {
		Self(keyPath: \.pinIcon)
	}
	
}
