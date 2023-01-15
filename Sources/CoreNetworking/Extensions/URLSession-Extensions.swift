//
//  URLSession-Extensions.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 29/11/2017.
//  Copyright © 2017 Greener Pastures. All rights reserved.
//

import Foundation
import CoreData
import RemoteLog
import Core
import CoreDataManager

/// Protocol for API responses, where responses may contain business errors.
public protocol ErrorableResponse {
	/// Error type that might be contained
	associatedtype ErrorType: LocalizedError
	
	var error: ErrorType? { get }
}

extension URLSession {
	/**
	Extension that:
	1) Creates a data task and calls resume on it.
	2) Parses response or errors.
	3) Shows/hides GPNetworkIndicator.
	
	- parameter request        		URLRequest to execute.
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter dateFormatter:		DateFormatter for parsing JSON date strings into Date objects
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	- parameter completion     		Result containing parsed response or Error.
	*/
	public func execute<T: Decodable>(_ request: URLRequest, errorIdentifier: String, dateFormatter: ImmutableDateFormatter? = nil, retryOptions: RetryTask? = nil, validStatuses: Range<Int> = Range( 200...399 ), excludeLoggingFor excludedStatuses: Set<Int> = [], completion: @escaping ( Result<T, Error> ) -> Void ) {
		executeTask(completion: completion) {
			try await self.execute(request,
								   errorIdentifier: errorIdentifier,
								   jsonDecoder: .make(with: dateFormatter),
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

	- parameter request        		URLRequest to execute.
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter dateFormatter:		DateFormatter for parsing JSON date strings into Date objects
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	- parameter completion     		Result containing parsed response or Error.
	*/
	public func execute<T: Decodable & ErrorableResponse>(_ request: URLRequest, errorIdentifier: String, dateFormatter: ImmutableDateFormatter? = nil, retryOptions: RetryTask? = nil, validStatuses: Range<Int> = Range( 200...399 ), excludeLoggingFor excludedStatuses: Set<Int> = Set(), completion: @escaping ( Result<T, Error> ) -> Void ) {
		executeTask(completion: completion) {
			try await self.execute(request,
								   errorIdentifier: errorIdentifier,
								   jsonDecoder: .make(with: dateFormatter),
								   retryOptions: retryOptions,
								   validStatuses: validStatuses,
								   excludeLoggingFor: excludedStatuses)
		}
	}

	/**
	This function overloads the more general `execute` function with an extra `coreDataUpdater` parameter. Should be used when parsing Core Data objects.

	Extension that:
	1) Creates a data task and calls resume on it.
	2) Parses response or errors.
	3) Shows/hides GPNetworkIndicator.

	- parameter request        			URLRequest to execute.
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter coreDataUpdater:	A classs with details of how to pefrom the update of existing Core Data objects.
	- parameter dateFormatter:		DateFormatter for parsing JSON date strings into Date objects
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	- parameter completion     		Result containing parsed response or Error.
	*/
	public func execute<T: Decodable, U: NSManagedObject & UpdatePolicyDelegate>(_ request: URLRequest, errorIdentifier: String, coreDataUpdater: CoreDataUpdater<U>, dateFormatter: ImmutableDateFormatter? = nil, retryOptions: RetryTask? = nil, validStatuses: Range<Int> = Range( 200...399 ), excludeLoggingFor excludedStatuses: Set<Int> = [], completion: @escaping ( Result<T, Error> ) -> Void ) {
		executeTask(completion: completion) {
			try await self.execute(request,
								   errorIdentifier: errorIdentifier,
								   coreDataUpdater: coreDataUpdater,
								   jsonDecoder: .make(with: dateFormatter),
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

	This function overloads the more general `execute` function to handle an ErrorResponse and return any errors from that.

	- parameter request        		URLRequest to execute.
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter dateFormatter:		DateFormatter for parsing JSON date strings into Date objects
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	- parameter completion     		Result containing parsed response or Error.
	*/
	public func execute<T: Decodable & ErrorableResponse, U: NSManagedObject & UpdatePolicyDelegate>(_ request: URLRequest, errorIdentifier: String, coreDataUpdater: CoreDataUpdater<U>, dateFormatter: ImmutableDateFormatter? = nil, retryOptions: RetryTask? = nil, validStatuses: Range<Int> = Range( 200...399 ), excludeLoggingFor excludedStatuses: Set<Int> = [], completion: @escaping ( Result<T, Error> ) -> Void ) {
		executeTask(completion: completion) {
			try await self.execute(request,
								   errorIdentifier: errorIdentifier,
								   coreDataUpdater: coreDataUpdater,
								   jsonDecoder: .make(with: dateFormatter),
								   retryOptions: retryOptions,
								   validStatuses: validStatuses,
								   excludeLoggingFor: excludedStatuses)
		}
	}
	
	private func executeTask<T>(completion: @escaping (Result<T, Error>) -> Void, request: @escaping () async throws -> T) {
		Task {
			do {
				try await completion(.success(request()))
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	// MARK: - Default session

	public static let core: URLSession = {
		let session: URLSession
		session = URLSession(configuration: .default)

		return session
	}()
}
