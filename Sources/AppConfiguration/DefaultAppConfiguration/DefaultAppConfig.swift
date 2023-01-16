//
//  DefaultAppConfig.swift
//  AppConfiguration
//
//  Created by Georgi Damyanov on 26/04/2021.
//

import CoopCore
import BaseAppConfiguration

/// Should be used only if the app contains the correct configuration `plist`, otherwise the app will crash. 
public let appConfig = AppConfig<DefaultAppConfigurationModel>()
