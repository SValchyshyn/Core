//
//  AppConfigCoordinator.swift
//  BaseAppConfiguration
//
//  Created by Olexandr Belozierov on 04.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit

public struct AppConfigCoordinator {
	
	private weak var presenter: UIViewController?
	private let viewModelFactory: () -> AppConfigViewModel
	
	public init<T: AppConfigurationProviding>(presenter: UIViewController, appConfig: AppConfig<T>, baseURLConfigurations: [BaseURLConfiguration]) {
		self.presenter = presenter
		
		viewModelFactory = {
			DefaultAppConfigViewModel(
				appConfig: appConfig,
				baseURLConfigurations: baseURLConfigurations)
		}
	}
	
	public func start() {
		let viewContoller = AppConfigViewController(viewModel: viewModelFactory())
		presenter?.present(viewContoller, animated: true)
	}
	
}
