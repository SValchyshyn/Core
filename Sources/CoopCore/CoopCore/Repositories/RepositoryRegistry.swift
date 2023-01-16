//
//  RepositoryRegistry.swift
//  CoopM16
//
//  Created by Christian Sjøgreen on 21/08/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

/// Keeps a list of Repositories so they can be reset when the user logs out.
public class RepositoryRegistry {
	public static let shared = RepositoryRegistry()
	
	private var registeredRepositories: SynchronizedArray<Repository> = .init()
	
	private init() {}
	
	/// Add Repository to the list.
	public func register( repository: Repository ) {
		registeredRepositories.append( repository )
	}
	
	/// Call `reset()` on all registered Repositories.
	public func resetAll() {
		registeredRepositories.rawArray.forEach { $0.clearAllData() }
	}
}
