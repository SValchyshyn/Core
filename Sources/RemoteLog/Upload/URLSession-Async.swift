//
//  URLSession-Async.swift
//  RemoteLog
//
//  Created by Adrian Ilie on 19.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

@available(iOS, deprecated: 15.0, message: "Use API available from Apple")
public extension URLSession {
	/// Download data for an URLRequest asynchronously.
	///
	/// - parameter request: request to perform
	/// - returns: downloaded data and server response
	func data(for request: URLRequest) async throws -> (Data, URLResponse) {
		var task: URLSessionDataTask?
		let taskCancel = {
			task?.cancel()
		}
		
		return try await withTaskCancellationHandler(operation: {
			try await withCheckedThrowingContinuation { continuation in
				task = self.dataTask(with: request) { data, response, error in
					guard let data = data, let response = response else {
						let error = error ?? URLError(.badServerResponse)
						return continuation.resume(throwing: error)
					}
					
					continuation.resume(returning: (data, response))
				}
				task?.resume()
			}
		}, onCancel: {
			taskCancel()
		})
	}
	
	/// Download data for an URL asynchronously.
	///
	/// - parameter url: request's url to perform
	/// - returns: downloaded data and server response
	func data(from url: URL) async throws -> (Data, URLResponse) {
		try await data(for: URLRequest(url: url))
	}
}
