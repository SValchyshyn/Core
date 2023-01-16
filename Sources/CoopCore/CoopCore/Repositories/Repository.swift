//
//  Repository.swift
//  CoopM16
//
//  Created by Christian Sjøgreen on 21/08/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

/// A type of "data manager" that registers itself with RepositoryRegistry and can have its content reset.
public protocol Repository: AnyObject {
	/// Register self in RepositoryRegistry so data can be cleared when user logs out. (Default implementation provided.)
	func registerRepository()
	
	/// Clear all content in this Repository. Must be overridden by class, that conforms to this protocol.
	func clearAllData()
}

public extension Repository {
	func registerRepository() {
		RepositoryRegistry.shared.register( repository: self )
	}
}
