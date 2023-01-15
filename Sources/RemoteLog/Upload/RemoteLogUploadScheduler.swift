//
//  RemoteLogUploadScheduler.swift
//  RemoteLog
//
//  Created by Adrian Ilie on 19.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

actor RemoteLogUploadScheduler {
	private let repository: RemoteLogRepositoryProvider
	private let uploadService: RemoteLogUploadServiceProvider
	private let retryHandler: RetryHandler = .init(retryDelay: 15.0, maxRetryDelay: 60.0)
	
	init(repository: RemoteLogRepositoryProvider, uploadService: RemoteLogUploadServiceProvider) {
		self.repository = repository
		self.uploadService = uploadService
	}
	
	func start() {
		stop()

		uploadTask = Task.detached(operation: {
			await self.upload()
		})
	}
	
	func stop() {
		uploadTask?.cancel()
	}
	
	// MARK: - Upload
	
	private var uploadTask: Task<Void, Never>?
	
	private nonisolated func upload() async {
		while !Task.isCancelled {
			// check if there is a log entry to be sent
			for await (identifier, entry) in RemoteLogEntriesProvider(repository: repository) {
				// send log entry to server
				do {
					try await self.uploadService.upload(entry)
					try await self.repository.markAsTransffered(identifier)
					// Reset the failed retries count on success to restore the regular retry interval
					retryHandler.resetFailedRetriesCount()
				} catch { // upload failed
					try? await self.repository.markAsNotTransffered(identifier)
					// Increase failed retries count on failure and break out to prevent infinite loop
					retryHandler.increaseFailedRetriesCount()
					break
				}
			}

			try? await retryHandler.awaitForRetry()
		}
	}
}

private class RetryHandler {

	/// Regular retry interval in seconds.
	private let retryInterval: TimeInterval

	/// Maximal retry interval in seconds.
	private let maxRetryInterval: TimeInterval

	/// Amount of failed retries.
	private var failedRetriesCount: Int = 0

	init(retryDelay: TimeInterval, maxRetryDelay: TimeInterval) {
		self.retryInterval = retryDelay
		self.maxRetryInterval = maxRetryDelay
	}

	/// Waits for the appropriate time interval before allowing retry attempt.
	func awaitForRetry() async throws {
		let currentRetryInterval = retryInterval * Double(failedRetriesCount)
		let normalizedRetryInterval = min(max(currentRetryInterval, retryInterval), maxRetryInterval)
		let retryIntervalInNanoseconds = UInt64(normalizedRetryInterval * 1_000_000_000)
		try await Task.sleep(nanoseconds: retryIntervalInNanoseconds)
	}

	/// Increases the number of failed reties which affects the retry interval delay.
	func increaseFailedRetriesCount() {
		failedRetriesCount += 1
	}

	/// Resets the failed retries counter which restores the regular retry interval delay.
	func resetFailedRetriesCount() {
		failedRetriesCount = 0
	}

}
