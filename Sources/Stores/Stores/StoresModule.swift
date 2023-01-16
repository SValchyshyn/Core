//
//  StoresModule.swift
//  Stores
//
//  Created by Stepan Valchyshyn on 04.08.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Core

public final class StoresModule {
	// MARK: - Singleton
	public static let shared = StoresModule()
	private init() {}
}

extension StoresModule: ServiceLocatorModule {
	// Register Store module provided dependencies
	public func registerServices(_ serviceLocator: ServiceLocator) {
		let storesRepository = StoresRepositoryImpl()
		serviceLocator.registerSingleton( storesRepository as StoresRepository )
		serviceLocator.registerSingleton( storesRepository as FilteredChainProvider )
	}
}
