//
//  ImageLoader.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 12.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

struct ImageLoader {
	
	static let shared = ImageLoader()
	
	private let session: URLSession
	private let tasksHandler = UniqueAsyncTaskPerformer<URLRequest, Data>()
	
	init() {
		// Use configuration without cache
		let configuration = URLSessionConfiguration.ephemeral
		configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
		configuration.urlCache = nil
		configuration.waitsForConnectivity = true
		
		let session = URLSession(configuration: configuration)
		self.init(session: session)
	}
	
	init(session: URLSession) {
		self.session = session	
	}
	
	/// Loads image data by url request.
	func imageData(for urlRequest: URLRequest) async throws -> Data {
		try await session.execute(request: urlRequest, errorIdentifier: "imageLoader.load").0
	}
	
}
