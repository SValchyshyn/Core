//
//  Tracking+Event.swift
//  Tracking
//
//  Created by Olexandr Belozierov on 26.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

extension Tracking {
	
	/// Tracking event.
	public struct Event: Hashable, ExpressibleByStringLiteral {
		
		/// Event name.
		public struct Name: Hashable, RawRepresentable, ExpressibleByStringLiteral {
			
			public let rawValue: String
			
			public init(rawValue value: String) {
				rawValue = value
			}
			
			public init(stringLiteral value: String) {
				rawValue = value
			}
			
		}
		
		let name: Name
		var parameters: [Parameter]
		let includeExtraInfo: Bool
		
		public init(name: String, parameters: [Parameter] = [], includeExtraInfo: Bool = true) {
			self.name = .init(rawValue: name)
			self.parameters = parameters
			self.includeExtraInfo = includeExtraInfo
		}
		
		public init(name: Name, parameters: [Parameter] = [], includeExtraInfo: Bool = true) {
			self.name = name
			self.parameters = parameters
			self.includeExtraInfo = includeExtraInfo
		}
		
		public init(stringLiteral value: String) {
			self.init(name: Name(rawValue: value))
		}
		
		// MARK: Append parameters
		
		public func appendingParameters(_ parameters: [Parameter]) -> Event {
			Event(name: name, parameters: self.parameters + parameters, includeExtraInfo: includeExtraInfo)
		}
		
		public func appendingParameter(_ parameter: Parameter) -> Event {
			appendingParameters([parameter])
		}
		
		public func appendingParameter(key: Parameter.Key, value: String) -> Event {
			appendingParameter(.init(key: key, value: value))
		}
		
		public func appendingParameter<T: RawRepresentable>(key: Parameter.Key, value: T) -> Event where T.RawValue == String {
			appendingParameter(.init(key: key, value: value))
		}
		
		public func appendingParameter(key: Parameter.Key, values: [String]) -> Event {
			appendingParameter(.init(key: key, values: values))
		}
		
		// MARK: Mutating parameters
		
		public mutating func appendParameters(_ parameters: [Parameter]) {
			self.parameters += parameters
		}
		
		public mutating func appendParameter(_ parameter: Parameter) {
			parameters.append(parameter)
		}
		
		public mutating func appendParameter(key: Parameter.Key, value: String) {
			appendParameter(.init(key: key, value: value))
		}
		
		public mutating func appendParameter<T: RawRepresentable>(key: Parameter.Key, value: T) where T.RawValue == String {
			appendParameter(.init(key: key, value: value))
		}
		
		public mutating func appendParameter(key: Parameter.Key, values: [String]) {
			appendParameter(.init(key: key, values: values))
		}
		
	}
	
}
