//
//  URLSession+AsyncExecute.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 18.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import CoreData
import Log
import Core
import CoreDataManager

public extension URLSession {
	
	private var proxyURLHandler: GeneralURLHandler? { ServiceLocator.injectSafe() }
	
	/**
	Extension that:
	1) Creates a data task and calls resume on it.
	2) Parses response or errors.
	
	- parameter request        		URLRequest to execute.
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	*/
	func execute<T: Decodable>(_ request: URLRequest, errorIdentifier: String, jsonDecoder: JSONDecoder = JSONDecoder(), retryOptions: RetryTask? = nil, validStatuses: Range<Int> = 200..<400, excludeLoggingFor excludedStatuses: Set<Int> = [], returning type: T.Type = T.self) async throws -> T {
		try await execute(
			request: request,
			errorIdentifier: errorIdentifier,
			retryOptions: retryOptions,
			validStatuses: validStatuses,
			excludeLoggingFor: excludedStatuses,
			decoder: DecodableDataTaskResponseDecoder(
				request: request,
				errorIdentifier: errorIdentifier,
				jsonDecoder: jsonDecoder))
	}
	
	/**
	Extension that:
	1) Creates a data task and calls resume on it.
	2) Returns Data and URLResponse without parsing/decoding Data.
	
	- parameter request        			URLRequest to execute.
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	*/
	func execute(_ request: URLRequest, errorIdentifier: String, retryOptions: RetryTask? = nil, validStatuses: Range<Int> = 200..<400, excludeLoggingFor excludedStatuses: Set<Int> = []) async throws -> (Data, URLResponse) {
		try await execute(request: request,
						  errorIdentifier: errorIdentifier,
						  retryOptions: retryOptions,
						  validStatuses: validStatuses,
						  excludeLoggingFor: excludedStatuses)
	}

	/**
	Extension that:
	1) Creates a data task and calls resume on it.
	2) Parses response or errors.

	- parameter request        		URLRequest to execute.
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	*/
	func execute<T: Decodable & ErrorableResponse>(_ request: URLRequest, errorIdentifier: String, jsonDecoder: JSONDecoder = JSONDecoder(), retryOptions: RetryTask? = nil, validStatuses: Range<Int> = 200..<400, excludeLoggingFor excludedStatuses: Set<Int> = [], returning type: T.Type = T.self) async throws -> T {
		let response: T = try await execute(
			request: request,
			errorIdentifier: errorIdentifier,
			retryOptions: retryOptions,
			validStatuses: validStatuses,
			excludeLoggingFor: excludedStatuses,
			decoder: DecodableDataTaskResponseDecoder(
				request: request,
				errorIdentifier: errorIdentifier,
				jsonDecoder: jsonDecoder))
		
		// Check for server side errors in the response
		guard let error = response.error else { return response }
		
		Log.technical.log(.error, error.localizedDescription, [.identifier(errorIdentifier + ".9"), .urlRequest(request)])
		
		throw error
	}
	
	/**
	This function overloads the more general `execute` function with an extra `coreDataUpdater` parameter. Should be used when parsing Core Data objects.

	Extension that:
	1) Creates a data task and calls resume on it.
	2) Parses response or errors.

	- parameter request        			URLRequest to execute.
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter coreDataUpdater:	A classs with details of how to pefrom the update of existing Core Data objects.
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	*/
	func execute<T: Decodable, U: NSManagedObject & UpdatePolicyDelegate>(_ request: URLRequest, errorIdentifier: String, coreDataUpdater: CoreDataUpdater<U>, jsonDecoder: JSONDecoder = JSONDecoder(), retryOptions: RetryTask? = nil, validStatuses: Range<Int> = 200..<400, excludeLoggingFor excludedStatuses: Set<Int> = [], returning type: T.Type = T.self) async throws -> T {
		try await execute(
			request: request,
			errorIdentifier: errorIdentifier,
			retryOptions: retryOptions,
			validStatuses: validStatuses,
			excludeLoggingFor: excludedStatuses,
			decoder: ManagedObjectDataTaskResponseDecoder(
				coreDataUpdater: coreDataUpdater,
				jsonDecoder: jsonDecoder))
	}
	
	/**
	Extension that:
	1) Creates a data task and calls resume on it.
	2) Parses response or errors.

	This function overloads the more general `execute` function to handle an ErrorResponse and return any errors from that.

	- parameter request        		URLRequest to execute.
	- parameter errorIdentifier:	Identifier for logging errors remotely
	- parameter retryOptions:		When set requests that fail due to network issues will be retried automatically according to the given configuration.
	- parameter excludeLoggingFor:	Set of status codes for which logging should not be performed
	*/
	func execute<T: Decodable & ErrorableResponse, U: NSManagedObject & UpdatePolicyDelegate>(_ request: URLRequest, errorIdentifier: String, coreDataUpdater: CoreDataUpdater<U>, jsonDecoder: JSONDecoder = JSONDecoder(), retryOptions: RetryTask? = nil, validStatuses: Range<Int> = 200..<400, excludeLoggingFor excludedStatuses: Set<Int> = [], returning type: T.Type = T.self) async throws -> T {
		let response: T = try await execute(
			request: request,
			errorIdentifier: errorIdentifier,
			retryOptions: retryOptions,
			validStatuses: validStatuses,
			excludeLoggingFor: excludedStatuses,
			decoder: ManagedObjectDataTaskResponseDecoder(
				coreDataUpdater: coreDataUpdater,
				jsonDecoder: jsonDecoder))
		
		// Check for server side errors in the response
		guard let error = response.error else { return response }
		
		Log.technical.log(.error, error.localizedDescription, [.identifier(errorIdentifier + ".9"), .urlRequest(request)])
		
		throw error
	}
	
	// MARK: Execute data task with DataTaskResponseDecoder
	
	/// Executes request and parse it usind decoder.
	private func execute<Decoder: DataTaskResponseDecoder>(request: URLRequest, errorIdentifier: String, retryOptions: RetryTask?, validStatuses: Range<Int>, excludeLoggingFor excludedStatuses: Set<Int>, decoder: Decoder) async throws -> Decoder.Response { // swiftlint:disable:this function_parameter_count - We really need all those parameters. -FAIO
		do {
			let (data, response) = try await execute(request: request,
													 errorIdentifier: errorIdentifier,
													 retryOptions: retryOptions)
			
			try validateResponse(response,
								 data: data,
								 request: request,
								 errorIdentifier: errorIdentifier,
								 validStatuses: validStatuses,
								 excludeLoggingFor: excludedStatuses)
			
			return try await decoder.decode(data: data)
		} catch {
			proxyURLHandler?.handle(error: error)
			throw error
		}
	}
	
	// MARK: Execute data task

	/// Executes request, validates it and returns Data and URLResponse without parsing/decoding Data.
	private func execute(request: URLRequest, errorIdentifier: String, retryOptions: RetryTask?, validStatuses: Range<Int>, excludeLoggingFor excludedStatuses: Set<Int>) async throws -> (Data, URLResponse) {
		do {
			let (data, response) = try await execute(request: request,
													 errorIdentifier: errorIdentifier,
													 retryOptions: retryOptions)

			try validateResponse(response,
								 data: data,
								 request: request,
								 errorIdentifier: errorIdentifier,
								 validStatuses: validStatuses,
								 excludeLoggingFor: excludedStatuses)

			return (data, response)
		} catch {
			proxyURLHandler?.handle(error: error)
			throw error
		}
	}
	
	/// Validate response based on status codes.
	private func validateResponse(_ response: URLResponse, data: Data, request: URLRequest, errorIdentifier: String, validStatuses: Range<Int>, excludeLoggingFor excludedStatuses: Set<Int>) throws { // swiftlint:disable:this function_parameter_count - We really need all those parameters. -FAIO
		// Validate response as HTTPURLResponse
		guard let response = response as? HTTPURLResponse else {
			Log.technical.log(.error, "Invalid response.", [.identifier(errorIdentifier + ".2"), .urlRequest(request)])
			throw APIError.invalidResponse
		}

		// Return error if response HTTP status is outside "success" range.
		guard !validStatuses.contains(response.statusCode) else { return }
		
		// Check whether the logging should be performed for the current status code
		if !excludedStatuses.contains(response.statusCode) {
			Log.technical.log(.error, "HTTP status error. Status: \(response.statusCode)", [.identifier(errorIdentifier + ".4"), .urlRequest(request)])
		}
		
		let errorString = String(data: data, encoding: .utf8)
		throw APIError.httpStatusError(statusCode: response.statusCode, errorString: errorString, payload: data)
	}
	
}
