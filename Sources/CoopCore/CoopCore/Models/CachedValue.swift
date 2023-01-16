//
//  CachedValue.swift
//  CoopM16
//
//  Created by Christian Sjøgreen on 16/08/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

/// A minimal single-value cache.
public struct CachedValue<T> {
	/// Value being cached.
	public let value: T
	
	/// Date when the value was received.
	public let timestamp: Date

	/// Maximum number of seconds until the cached value is expired. Set to nil to never expire.
	public let timeToLive: TimeInterval?

	/// Public initializer accessible from other modules, since the default struct initializer is `internal`.
	public init( value: T, timestamp: Date, timeToLive: TimeInterval? = nil ) {
		self.value = value
		self.timestamp = timestamp
		self.timeToLive = timeToLive
	}
}

public extension CachedValue {
	/// Conveniene init for caching a value with timestamp = now.
	init( value: T, timeToLive: TimeInterval? = nil ) {
		self.value = value
		self.timeToLive = timeToLive
		timestamp = Date()
	}
	
	/// Returns true when timestamp + timeToLive is in the future. Always returns true if timeToLive is nil.
	var isValid: Bool {
		guard let timeToLive = self.timeToLive else { return true }
		return timestamp.addingTimeInterval( timeToLive ) > Date()
	}
	
	/// Returns true when timestamp + timeToLive is in the past. Always returns false if timeToLive is nil.
	var isExpired: Bool {
		guard let timeToLive = self.timeToLive else { return false }
		return timestamp.addingTimeInterval( timeToLive ) < Date()
	}
}
