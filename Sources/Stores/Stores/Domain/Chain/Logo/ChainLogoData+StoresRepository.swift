//
//  ChainLogoData+StoresRepository.swift
//  Stores
//
//  Created by Oleksandr Belozierov on 09.12.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Core

extension ChainLogoData {
	
	@Injectable private static var storesRepository: StoresRepository
	
	/// Provides logo data by getting from `StoresRepository`.
	public static func storesRepository(with chainID: Chain.ID?) -> Self {
		guard let chainID else { return Self(chain: nil) }
		return .init { try? await Self.storesRepository.getChain(chainId: chainID) }
	}
	
}
