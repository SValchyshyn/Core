//
//  StoresRepository.swift
//  Stores
//
//  Created by Stepan Valchyshyn on 04.08.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import CoopCore

public protocol StoresRepository: Repository {
	/// Get all available Stores
	func getStores() async throws -> [Store]
	
	/// Get single Store info by `storeId`
	func getStore( storeId: String ) async throws -> Store
	
	/// Get all available stores related by `chainId`
	func getStores( chainId: String ) async throws -> [Store]
	
	/// Get all available chains
	func getChains() async throws -> [Chain]
	
	/// Get single Chain info by `chainId`
	func getChain( chainId: String ) async throws -> Chain
}

public protocol FilteredChainProvider {
	/**
	 Get the chains with the given chain IDs
	 - parameter chainIDs: The chains we want to be present in the returned array
	*/
	func filteredChains( chainIDs: [String] ) async throws -> [Chain]
}
