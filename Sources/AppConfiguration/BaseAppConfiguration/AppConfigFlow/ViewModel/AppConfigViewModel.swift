//
//  AppConfigViewModel.swift
//  BaseAppConfiguration
//
//  Created by Olexandr Belozierov on 04.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Combine

protocol AppConfigViewModel: AnyObject {
	
	// MARK: Base URL
	
	var baseURLConfigurationTitles: [String] { get }
	
	var selectedBaseURLConfigurationIndex: Int? { get set }
	
	// MARK: App Config
	
	var appConfigVersionPublisher: AnyPublisher<String?, Never> { get }
	
	func resetAppConfig()
	
	// MARK: - Options
	
	func clearAllData()
	
	// MARK: Helpers
	
	var errorPublisher: AnyPublisher<Error, Never> { get }
	
}
