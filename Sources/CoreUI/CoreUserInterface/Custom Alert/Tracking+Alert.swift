//
//  Tracking+Alert.swift
//  CoreUserInterface
//
//  Created by Olexandr Belozierov on 02.06.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Tracking

extension Tracking.Parameter {
	enum Alert {} // Namespace
	static let alert = Alert.self
}

extension Tracking.Parameter.Alert {
	
	static let alertEventType = Tracking.Parameter(key: "event_type", value: "alert")
	
}
