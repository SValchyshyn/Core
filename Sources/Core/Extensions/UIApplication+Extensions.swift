//
//  UIApplication+Extensions.swift
//  CoopUI
//
//  Created by Coruț Fabrizio on 13.12.2021.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
	
	/// `iOS 15` compatible way of fetching the `current key window` out of all the possible scenes.
	static var currentKeyWindow: UIWindow? {
		UIApplication.shared.connectedScenes.lazy
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first { $0.isKeyWindow }
	}
}
