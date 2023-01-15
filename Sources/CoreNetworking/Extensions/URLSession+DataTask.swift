//
//  URLSession+DataTask.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 18.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import RemoteLog
import Core
import Log

extension URLSession {
	
	/// URLSessionTask holder to start/cancel task.
	private actor DataTask {
		
		private typealias Continuation = CheckedContinuation<(Data, URLResponse), Error>
		
		// Initiate data
		private let session: URLSession
		private let request: URLRequest
		private let errorIdentifier: String
		
		// State
		private var task: URLSessionTask?
		private var continuation: Continuation?
		private var isCancelled = false
		
		init(session: URLSession, request: URLRequest, errorIdentifier: String) {
			self.session = session
			self.request = request
			self.errorIdentifier = errorIdentifier
		}
		
		nonisolated func start() async throws -> (Data, URLResponse) {
			try await Task(operation: _start).value
		}
		
		@Sendable private func _start() async throws -> (Data, URLResponse) {
			if isCancelled || Task.isCancelled { throw URLError(.cancelled) }
			return try await withCheckedThrowingContinuation(createTask)
		}
		
		// MARK: Create data task
		
		private func createTask(with continuation: Continuation) {
			self.continuation = continuation
			
			task = session.dataTask(with: request) { data, response, error in
				if let data = data, let response = response {
					return self.complete(with: .success((data, response)))
				}
				
				let error = APIError.networkError(error ?? URLError(.badServerResponse))
				Log.technical.logNetworkError(error, origin: "", [.identifier(self.errorIdentifier + ".1"), .urlRequest(self.request)])
				return self.complete(with: .failure(error))
			}
			
			task?.resume()
		}
		
		private func complete(with result: Result<(Data, URLResponse), Error>) {
			guard let continuation = continuation else { return }
			self.continuation = nil
			continuation.resume(with: result)
		}
		
		// MARK: Cancel
		
		@Sendable nonisolated func cancel() {
			Task { await _cancel() }
		}
		
		private func _cancel() {
			isCancelled = true
			task?.cancel()
			task = nil
			complete(with: .failure(URLError(.cancelled)))
		}
		
		deinit {
			_cancel()
		}
		
	}
	
	// MARK: Execute data task
	
	/// Executes request in async/await style.
	func execute(request: URLRequest, errorIdentifier: String) async throws -> (Data, URLResponse) {
		if let (data, response) = mockData(for: request) {
			return (data, response)
		}
		
		if #available(iOS 15, *) {
			return try await data(for: request, errorIdentifier: errorIdentifier)
		} else {
			let dataTask = DataTask(session: self, request: request, errorIdentifier: errorIdentifier)
			return try await withTaskCancellationHandler(operation: dataTask.start, onCancel: dataTask.cancel)
		}
	}
	
	@available(iOS 15, *)
	private func data(for request: URLRequest, errorIdentifier: String) async throws -> (Data, URLResponse) {
		do {
			return try await data(for: request)
		} catch {
			Log.technical.logNetworkError(error, origin: "", [.identifier(errorIdentifier + ".1"), .urlRequest(request)])
			throw error
		}
	}
	
	// MARK: Execute data task with retry task
	
	/// Executes request in async/await style with retries on error.
	func execute(request: URLRequest, errorIdentifier: String, retryOptions: RetryTask? = nil) async throws -> (Data, URLResponse) {
		do {
			return try await execute(request: request, errorIdentifier: errorIdentifier)
		} catch {
			guard let retryOptions = retryOptions, retryOptions.shouldRetryAfter(error) else { throw error }
			try await retryOptions.awaitForRetry(logIdentifier: errorIdentifier + ".retrying", error: error)
			return try await execute(request: request, errorIdentifier: errorIdentifier, retryOptions: retryOptions)
		}
	}
	
	// MARK: Mock response
	
	/// Tries to get mock data.
	private func mockData(for request: URLRequest) -> (Data, URLResponse)? {
		// Check if the response mocking is enabled.
		guard MockResponseProvider.isMockingEnabled else { return nil }

		// Try mocking the response for provided request.
		return MockResponseProvider.shared.mockResponse(for: request).map { ($1, $0) }
	}
	
}
