//
//  ChainFilterManager.swift
//  StoresData
//
//  Created by Coruț Fabrizio on 23.10.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation

/// Manages and handles the storage of a certain `Chain filter`.
/// The `filter` is an `out filter`, meaning that the value handled by the manager is actually representing all the
/// `Chains` that should be excluded from a possible list of `Chains`.
open class ChainFilterManager {

	// MARK: - Public interface.

	/// The notification specific for the context in which the `ChainFilterManager` is used.
	public let featureSpecificNotificationName: Notification.Name
	
	/// _All_ the `Chains` that the user can filter upon.
	open var allChains: [Chain] {
		fatalError( "Override in subclass." )
	}
	
	// MARK: - Init
	
	/// - Parameters:
	///   - notificationName: The notification specific for the context in which the `ChainFilterManager` is used.
	public init( notificationName: Notification.Name ) {
		self.featureSpecificNotificationName = notificationName
	}
	
	/// - Returns: The disjoint set created by `subtracting the result getFilter()` and `allChains`.
	open func getFilteredInChains() -> Set<Chain> {
		Set( allChains ).subtracting( getFilter() )
	}
	
	/// - Returns: The current `filter` managed by this manager.
	open func getFilter() -> Set<Chain> {
		fatalError( "Override in subclass." )
	}
	
	/// Updates the current manager's `filter`.
	/// Base class only posts a notification informing the listeners that the `ChainFilterManager` specific filter has been updated.
	/// - Parameter filter: The value with which the current `filter` should be replaced.
	open func set( filter: Set<Chain> ) {
		// Notify that there are new values.
		NotificationCenter.default.post( name: featureSpecificNotificationName, object: self )
	}
}
