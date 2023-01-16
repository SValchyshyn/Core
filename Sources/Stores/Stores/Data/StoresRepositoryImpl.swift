//
//  StoresRepositoryImpl.swift
//  Stores
//
//  Created by Stepan Valchyshyn on 05.08.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import Core
import CoopCore
import Log

public actor StoresRepositoryImpl: StoresRepository {
	private enum Constants {
		/// `Store`and `Chain` data validity period, in seconds.
		static let storesDataTTL: TimeInterval = 60 * 60
	}
	
	// MARK: - Properties.

	/// Keeps a reference to stores cache and a timestamp.
	private var _storesCachedValue: CachedValue<[Store]>
	
	/// Keeps a reference to chains cache and a timestamp.
	private var _chainsCachedValue: CachedValue<[Chain]>
	private let _storesAPI = StoresAPIImpl()
	private var pendingStoresTask: Task<[Store], Error>?
	private var pendingChainsTask: Task<[Chain], Error>?

	public init() {
		// Init the cached value.
		_storesCachedValue = .init( value: .init(), timestamp: .distantPast, timeToLive: Constants.storesDataTTL )
		_chainsCachedValue = .init( value: .init(), timestamp: .distantPast, timeToLive: Constants.storesDataTTL )

		// Register as repository, so `clearAllData()` can be called when the user logs out.
		registerRepository()
	}
	
	public func getStores() async throws -> [Store] {
		// First of all, check if we have a valid cache
		if _storesCachedValue.isValid {
			// Return a valid cache
			return _storesCachedValue.value
		} else if let storesTask = pendingStoresTask {
			// If no cache, check if we already have a stores task executing. If so - await for result of that task
			return try await storesTask.value
		} else {
			// If no cache and pending task - make a new stores task
			defer {
				// Clear `pendingStoresTask` on finish
				pendingStoresTask = nil
			}
			
			let newStoresTask = Task.detached { try await self.fetchAndSaveStores()}
			pendingStoresTask = newStoresTask
			
			return try await newStoresTask.value
		}
	}
	
	public nonisolated func getStore( storeId: String ) async throws -> Store {
		let stores = try await getStores()
		if let store = stores.first( where: { $0.id == storeId } ) {
			return store
		} else {
			throw DataError.missing
		}
	}
	
	public nonisolated func getStores( chainId: String ) async throws -> [Store] {
		return try await getStores().filter({ $0.chain.id == chainId })
	}
	
	public func getChains() async throws -> [Chain] {
		// First of all, check if we have a valid cache
		if _chainsCachedValue.isValid {
			// Return a valid cache
			return _chainsCachedValue.value
		} else if let chainsTask = pendingChainsTask {
			// If no cache, check if we already have a stores task executing. If so - await for result of that task
			return try await chainsTask.value
		} else {
			// If no cache and pending task - make a new stores task
			defer {
				// Clear `pendingStoresTask` on finish
				pendingChainsTask = nil
			}
			
			let newChainsTask = Task.detached { try await self.fetchAndSaveChains()}
			pendingChainsTask = newChainsTask
			
			return try await newChainsTask.value
		}
	}
	
	public nonisolated func getChain( chainId: String ) async throws -> Chain {
		do {
			let chains = try await getChains()
			if let chain = chains.first( where: { $0.id == chainId } ) {
				return chain
			} else {
				throw DataError.missing
			}
		} catch {
			Log.technical.log(.error, "Failed to get chain for chainId:\(chainId) with an error:\(error).", [.identifier("StoresRepositoryImpl.getChain")])
			throw error
		}
	}
	
	/// Remove all cached data
	nonisolated public func clearAllData() {
		Task { await _clearAllData() }
	}
	
	private func _clearAllData() {
		// Remove in-memory cached values.
		_storesCachedValue = .init( value: .init(), timestamp: .distantPast, timeToLive: 0.0 )
		_chainsCachedValue = .init( value: .init(), timestamp: .distantPast, timeToLive: 0.0 )
	}
}

extension StoresRepositoryImpl {
	private func fetchAndSaveStores() async throws -> [Store] {
		do {
			let stores = try await _storesAPI.getStores()
			_storesCachedValue = .init( value: stores, timeToLive: Constants.storesDataTTL )
			return stores
		} catch {
			Log.technical.log(.error, "Failed to get stores with an error:\(error).", [.identifier("StoresRepositoryImpl.fetchAndSaveStores")])
			throw error
		}
	}
	
	private func fetchAndSaveChains() async throws -> [Chain] {
		do {
			let chains = try await _storesAPI.getChains().removingDuplicates()
			_chainsCachedValue = .init( value: chains, timeToLive: Constants.storesDataTTL )
			return chains
		} catch {
			Log.technical.log(.error, "Failed to get chains with an error:\(error).", [.identifier("StoresRepositoryImpl.fetchAndSaveChains")])
			throw error
		}
	}
}

/**
Provide a default `CouponsChainProvider` for the store repository
*/
extension StoresRepositoryImpl: FilteredChainProvider {
	public func filteredChains( chainIDs: [String] ) async throws -> [Chain] {
		return try await getChains().filter { chainIDs.contains($0.id) }
	}
}
