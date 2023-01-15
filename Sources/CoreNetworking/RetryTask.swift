//
//  RetryTask.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 02/03/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import Log
import Core

/**
Class intended for configuring retryable network requests
*/
public class RetryTask {
	/// The rate in seconds by which we increase the retry intervals
	private (set) var retryIncreaseInterval: TimeInterval = 1.0

	/// The maximum interval in seconds between the retry calls.
	private (set) var maximumRetryInterval: TimeInterval = 5.0

	/// The timeout for all the requests together, regardless of how many times we retry.
	private (set) var maxCombinedTimeout: TimeInterval = 30

	/// How long we have to wait until we retry the call again
	private (set) var currentRetryInterval: TimeInterval = 0.0

	/// The  timestamp of the first retry
	private (set) var taskCreationTimestamp: Date

	/// Flag indicating if we should log the retry attempts
	private (set) var shouldLogRetryAttempts = false

	/**
	- parameter retryIncreaseInterval: 	The time we are going to wait before attempting again.
	- parameter maximumRetryInterval: 	The maximum waiting time between requests.
	- parameter maxCombinedTimeout:			How much time we want to allocate for all the retry requests.
	*/
	public init( retryIncreaseInterval: TimeInterval = 1.0, maximumRetryInterval: TimeInterval = 5.0, maxCombinedTimeout: TimeInterval = 60.0, shouldLogRetryAttempts: Bool = false ) {
		self.retryIncreaseInterval = retryIncreaseInterval
		self.maximumRetryInterval = maximumRetryInterval
		self.maxCombinedTimeout = maxCombinedTimeout
		self.shouldLogRetryAttempts = shouldLogRetryAttempts
		taskCreationTimestamp = Date()
	}

	/**
	- returns: Boolean indicating if we can retry the request
	*/
	internal func shouldRetryAfter(_ error: Error ) -> Bool {
		// Check if we have not reached the combined timeout for the request
		guard -taskCreationTimestamp.timeIntervalSinceNow < maxCombinedTimeout else {
			return false
		}

		// We only retry network errors
		return error.isNetworkError
	}
	
	/// Sleeps current task to await for next retry.
	internal func awaitForRetry(logIdentifier: String, error: Error?) async throws {
		// Increase retry interval. Do not let it exceed the maximum waiting time.
		currentRetryInterval = min(retryIncreaseInterval + currentRetryInterval, maximumRetryInterval)

		// Execute the block after the current retry delay
		let nanoseconds = UInt64(currentRetryInterval * 1_000_000_000)
		try await Task.sleep(nanoseconds: nanoseconds)
		
		if shouldLogRetryAttempts {
			// Log the retry attempt
			if let error = error {
				Log.technical.log(.warning, "Retrying API call after a network error: \(error)", [.identifier(logIdentifier)])
			} else {
				Log.technical.log(.warning, "Retrying API call", [.identifier(logIdentifier)])
			}
		}
	}
	
}
