//
//  AppConfigCoordinator+Extensions.swift
//  DefaultAppConfiguration
//
//  Created by Olexandr Belozierov on 04.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit
import BaseAppConfiguration

public extension AppConfigCoordinator {
	
	static func `default`(presenter: UIViewController, baseURLConfigurations: [BaseURLConfiguration]) -> AppConfigCoordinator {
		AppConfigCoordinator(
			presenter: presenter,
			appConfig: appConfig,
			baseURLConfigurations: baseURLConfigurations)
	}
	
}
