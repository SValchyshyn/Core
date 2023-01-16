//
//  URLSession-AuthExtensions.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 09.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import Core
import CoreData
import CoreNetworking
import CoreDataManager
import DefaultAppConfiguration
import AuthenticationDomain

public extension URLSession {
	
	/**
	Extension that:
	1) Creates a data task and calls resume on it.
	2) Parses response or errors.
	3) Shows/hides GPNetworkIndicator.
	4) Refresh auth token if needed
	5) Renew a new token if needed
	
	- parameter requestData        	URLRequest wrapper to track auth token refresh/renew states for current request
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	*/
	func execute<T: Decodable>(_ request: URLRequest, auth: AccessTokenRequest, errorIdentifier: String, jsonDecoder: JSONDecoder = JSONDecoder(), retryOptions: RetryTask? = nil, validStatuses: Range<Int> = 200..<400, excludeLoggingFor excludedStatuses: Set<Int> = []) async throws -> T {
		try await execute(request, auth: auth) { request in
			try await execute(request,
							  errorIdentifier: errorIdentifier,
							  jsonDecoder: jsonDecoder,
							  retryOptions: retryOptions,
							  validStatuses: validStatuses,
							  excludeLoggingFor: excludedStatuses)
		}
	}
	
	/**
	Extension that:
	1) Creates a data task and calls resume on it.
	2) Parses response or errors.
	3) Shows/hides GPNetworkIndicator.
	4) Refresh auth token if needed
	5) Renew a new token if needed
	
	- parameter requestData        		URLRequest wrapper to track auth token refresh/renew states for current request
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter coreDataUpdater:	A classs with details of how to pefrom the update of existing Core Data objects.
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	*/
	func execute<T: Decodable, U: NSManagedObject & UpdatePolicyDelegate>(_ request: URLRequest, auth: AccessTokenRequest, errorIdentifier: String, coreDataUpdater: CoreDataUpdater<U>, retryOptions: RetryTask? = nil, validStatuses: Range<Int> = 200..<400) async throws -> T {
		try await execute(request, auth: auth) { request in
			try await execute(request,
							  errorIdentifier: errorIdentifier,
							  coreDataUpdater: coreDataUpdater,
							  retryOptions: retryOptions,
							  validStatuses: validStatuses)
		}
	}
	
	private func execute<T>(_ request: URLRequest, auth: AccessTokenRequest, taskExecutor: (URLRequest) async throws -> T) async throws -> T {
		let authManager: AuthenticationManager = ServiceLocator.inject()
		var request = request
		var triedToRenewToken = false
		
		func renewToken(for request: inout URLRequest) async throws {
			do {
				let token = try await authManager.renewAccessToken(for: auth)
				request.setBearerToken(token)
				triedToRenewToken = true // Save renew
			} catch {
				throw AuthManagerError.unavailableToken
			}
		}
		
		if let token = authManager.cachedAccessToken(for: auth) {
			request.setBearerToken(token) // Try with cached token first
		} else {
			try await renewToken(for: &request) // Get new token
		}
		
		while true { // Try again after refresh token
			try Task.checkCancellation()
			
			do {
				return try await taskExecutor(request)
			} catch APIError.httpStatusError(401, _, _) where !triedToRenewToken {
				try await renewToken(for: &request) // If 401 - try to refresh the token
			} catch APIError.httpStatusError(403, _, _) {
				throw AuthManagerError.unavailableToken
			} catch {
				throw error
			}
		}
	}
	
	/**
	Extension that:
	1) Creates a data task and calls resume on it.
	2) Parses response or errors.
	3) Shows/hides GPNetworkIndicator.
	4) Refresh auth token if needed
	5) Renew a new token if needed
	
	- parameter requestData        	URLRequest wrapper to track auth token refresh/renew states for current request
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter dateFormatter:		DateFormatter for parsing JSON date strings into Date objects
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	- parameter completion     		Result containing parsed response or Error.
	*/
	func execute<T: Decodable>(_ request: URLRequest, auth: AccessTokenRequest, errorIdentifier: String, dateFormatter: ImmutableDateFormatter? = nil, retryOptions: RetryTask? = nil, validStatuses: Range<Int> = 200..<400, excludeLoggingFor excludedStatuses: Set<Int> = [], completion: @escaping (Result<T, Error>) -> Void) {
		Task {
			do {
				let response: T = try await execute(request,
													auth: auth,
													errorIdentifier: errorIdentifier,
													jsonDecoder: .make(with: dateFormatter),
													retryOptions: retryOptions,
													validStatuses: validStatuses,
													excludeLoggingFor: excludedStatuses)
				completion(.success(response))
			} catch {
				completion(.failure(error))
			}
		}
	}
	
}

private extension URLRequest {
	
	mutating func setBearerToken(_ token: String) {
		setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
	}
	
}
