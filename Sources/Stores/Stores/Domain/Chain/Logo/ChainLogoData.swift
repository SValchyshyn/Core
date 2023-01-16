//
//  ChainLogoData.swift
//  Stores
//
//  Created by Oleksandr Belozierov on 09.12.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit
import Core
import CoreNetworking

/// Chain logo data representation. Implemented in async manner.
public struct ChainLogoData {
	
	private let chainProvider: () async -> Chain?
	
	/// Creates new instance with chain.
	public init(chain: Chain?) {
		chainProvider = { chain }
	}
	
	/// Creates new instance with async closure that provides chain.
	public init(chainProvider: @escaping () async -> Chain?) {
		let task = LazyTask(operation: chainProvider) // Load data lazily
		self.chainProvider = { await task.value }
	}
	
	/// Chain related color.
	public var chainColor: UIColor? {
		get async {
			await chainProvider()?.color
		}
	}
	
	/// Provides logo image URL for specific `ImageSource`.
	public func imageURL(for source: ImageSource) async -> URL? {
		await chainProvider().flatMap { source.urlProvider($0.urls) }
	}
	
}

extension ChainLogoData {
	
	/// Provides logo image for specific `ImageSource`.
	public func image(for source: ImageSource) async -> UIImage? {
		guard let url = await imageURL(for: source) else { return nil }
		return try? await ImageProvider.shared.image(for: URLRequest(url: url))
	}
	
}
