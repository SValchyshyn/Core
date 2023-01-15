//
//  Tracking+Parameter.swift
//  Tracking
//
//  Created by Olexandr Belozierov on 30.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

public extension Tracking {
	
	/// Tracking parameter that contains key/value pair.
	struct Parameter: Hashable {
		
		public let key: Key
		let value: String
		
		public init(key: String, value: String) {
			self.key = .init(rawValue: key)
			self.value = value
		}
		
		public init(key: Key, value: String) {
			self.key = key
			self.value = value
		}
		
		public init<T: RawRepresentable>(key: Key, value: T) where T.RawValue == String {
			self.init(key: key, value: value.rawValue)
		}
		
		public init(key: Key, value: () -> String) {
			self.init(key: key, value: value())
		}
		
		public init(key: Key, values: [String], separator: String = ",") {
			self.init(key: key, value: values.joined(separator: separator))
		}
		
	}
	
}

public extension Tracking.Parameter {
	
	/// Key type for tracking parameter.
	struct Key: Hashable, RawRepresentable, ExpressibleByStringLiteral {
		
		public let rawValue: String
		
		public init(rawValue value: String) {
			rawValue = value
		}
		
		public init(stringLiteral value: String) {
			rawValue = value
		}
		
	}
	
}

extension Array where Element == Tracking.Parameter {
	
	/// Converts array of paramters into dictionary
	var parametersDict: [String: String] {
		Dictionary(map { ($0.key.rawValue, $0.value) }, uniquingKeysWith: { _, new in new })
	}
	
}
