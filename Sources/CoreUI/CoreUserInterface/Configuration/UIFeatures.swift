//
//  UIFeatures.swift
//  CoreUserInterface
//
//  Created by Stepan Valchyshyn on 04.06.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Core

internal enum UIFeatures: Feature {
	case remoteLoggingAlerts
	
	public var identifier: String {
		switch self {
		case .remoteLoggingAlerts: return "remote_log_alerts"
		}
	}
}
