//
//  MockStoresAPI.swift
//  Stores
//
//  Created by Stepan Valchyshyn on 06.08.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import AuthenticationData

internal final class StoresAPIImpl: StoresAPI {	
	public init() {}
	
	func getStores() async throws -> [Store] {
		let endpoint: StoresAPIEndpoint = .stores
		let request: URLRequest = try .init( for: endpoint, httpMethod: .GET )
		let response: [StoreData] = try await URLSession.core.execute( request, auth: endpoint.tokenRequest, errorIdentifier: endpoint.errorIdentifier )
		return response.map { $0.mapToDomain() }
	}
	
	func getStore(storeId: String) async throws -> Store {
		let endpoint: StoresAPIEndpoint = .store( storeId: storeId )
		let request: URLRequest = try .init( for: endpoint, httpMethod: .GET )
		let response: StoreData = try await URLSession.core.execute( request, errorIdentifier: endpoint.errorIdentifier)
		
		return response.mapToDomain()
	}
	
	func getChains() async throws -> [Chain] {
		let endpoint: StoresAPIEndpoint = .chains
		let request: URLRequest = try .init(for: endpoint, httpMethod: .GET)
		let response: [ChainData] = try await URLSession.core.execute(request, auth: endpoint.tokenRequest, errorIdentifier: endpoint.errorIdentifier)
		return response.map{ $0.mapToDomain() }
	}
	
	func getChain(chainId: String) async throws -> Chain {
		let endpoint: StoresAPIEndpoint = .chain(chainId: chainId)
		let request: URLRequest = try .init(for: endpoint, httpMethod: .GET)
		let response: ChainData = try await URLSession.core.execute( request, errorIdentifier: endpoint.errorIdentifier)
		
		return response.mapToDomain()
	}
}
