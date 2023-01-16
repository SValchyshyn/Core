//
//  BaseURLConfiguration.swift
//  BaseAppConfiguration
//
//  Created by Olexandr Belozierov on 04.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public struct BaseURLConfiguration: Equatable {
	
	static let `default` = BaseURLConfiguration(name: "Default", host: nil)
	
	let name: String
	let host: String?
	
	public init(name: String, host: String) {
		self.name = name
		self.host = host
	}
	
	fileprivate init(name: String, host: String?) {
		self.name = name
		self.host = host
	}
	
	var baseURL: URL? {
		host.flatMap { URL(string: "https://\($0)") }
	}
	
}
