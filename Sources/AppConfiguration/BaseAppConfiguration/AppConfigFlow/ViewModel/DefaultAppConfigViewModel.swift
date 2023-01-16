//
//  DefaultAppConfigViewModel.swift
//  BaseAppConfiguration
//
//  Created by Olexandr Belozierov on 04.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Combine
import UserDefault
import CoopCore
import CoreDataManager

class DefaultAppConfigViewModel<T: AppConfigurationProviding>: AppConfigViewModel {
	
	private let appConfig: AppConfig<T>
	private let baseURLConfigurations: [BaseURLConfiguration]
	
	private let appVersionUpdateSubject = PassthroughSubject<String?, Never>()
	private let errorSubject = PassthroughSubject<Error, Never>()
	
	init(appConfig: AppConfig<T>, baseURLConfigurations: [BaseURLConfiguration]) {
		self.appConfig = appConfig
		self.baseURLConfigurations = [.default] + baseURLConfigurations
	}
	
	var errorPublisher: AnyPublisher<Error, Never> {
		errorSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
	}
	
	// MARK: Base URL
	
	var baseURLConfigurationTitles: [String] {
		baseURLConfigurations.map { $0.name }
	}
	
	var selectedBaseURLConfigurationIndex: Int? {
		get {
			let currentHost = appConfig.baseURL?.host
			return baseURLConfigurations.firstIndex { $0.host == currentHost }
		}
		set {
			let configuration = baseURLConfigurations[newValue ?? 0]
			appConfig.setCustomBaseURL(configuration.baseURL)
			resetAppConfig()
		}
	}
	
	// MARK: App Config
	
	var appConfigVersionPublisher: AnyPublisher<String?, Never> {
		Just(appConfig.appConfigVersion)
			.merge(with: appVersionUpdateSubject)
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
	
	func resetAppConfig() {
		appConfig.resetAppConfig()
		updateAppVersionSubject()
		
		Task{
			do {
				try await appConfig.fetchRemoteData()
				updateAppVersionSubject()
			} catch let error {
				errorSubject.send(error)
			}
		}
	}
	
	private func updateAppVersionSubject() {
		appVersionUpdateSubject.send(appConfig.appConfigVersion)
	}
	
	// MARK: - Options
	
	func clearAllData() {
		// clear user defaults
		UserDefaults.appSettings.clear()
		UserDefaults.userSettings.clear()
		
		// clear Keychain
		Keychain.clear()
		
		// clear CoreData storage
		CoreDataManager.shared.clear()
	}
}
