//
//  StoresAPI.swift
//  Stores
//
//  Created by Stepan Valchyshyn on 05.08.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

protocol StoresAPI {
	func getStores() async throws -> [Store]
	func getStore(storeId: String) async throws -> Store
	func getChains() async throws -> [Chain]
	func getChain(chainId: String) async throws -> Chain
}
