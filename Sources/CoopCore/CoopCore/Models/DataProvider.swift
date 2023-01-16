//
//  DataProvider.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 18/06/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// Encapsulation of data providing. Caches values and decides on a per-request basis whether the cached data should be used or new one should be fetched.
/// Synchronizes each `provideData` call so we don't make multiple fetch requests. Doesn't blockthe execution.
/// Since usually the model that we receive doesn't match the model that we want to use in the business logic, we must specialize this class'
/// `BusinessModel` and `ResponseModel` with the desired mapping.
final public class DataProvider<BusinessModel, ResponseModel> {
	/// Encapsulates the data and contains any additional context regarding the process of providing the data.
	public struct Response<T> {
		/// `true` if the `model` is the cached one.
		public let isCachedData: Bool

		/// Actual model.
		public let model: T
	}

	// MARK: - Properties

	/// Used to synchronize the access to `_cachedValue`.
	private let _semaphore: DispatchSemaphore = .init( value: 1 )

	/// Used to not block the main or any other thread during the synchronization of `_cachedValue`.
	private let _syncQueue: DispatchQueue = .init( label: "iOS.dataProvider.\(BusinessModel.self)" )

	/// Reference to the cached data.
	private var _cache: CachedValue<BusinessModel>

	/// Number of seconds for which the `cache` should be considered valid.
	private let _ttl: TimeInterval

	/// Used to make the transformation between the `ResponseModel` and the `BusinessModel`.
	private let _transform: ( ResponseModel ) throws -> BusinessModel

	/// Fetches new data from the server whenever the data is not valid anymore or the cache should be explicitly ignored.
	private let _fetchData: ( _ completion: @escaping ( Result<ResponseModel, Error> ) -> Void) -> Void

	// MARK: - Init

	/**
	- parameter initialValue:		Initial value of the `cache`.
	- parameter ttl:				Number of seconds which the `cache` will be considered valid.
	- parameter fetchData:			Server request for fetching the data.
	- parameter transform:			Mapping between the `ResponseModel` and `BusinessModel`. Called when new and if data is fetched.
	*/
	public init( initialValue: CachedValue<BusinessModel>,
				 ttl: TimeInterval,
				 fetchData: @escaping ( _ completion: @escaping ( Result<ResponseModel, Error> ) -> Void ) -> Void,
				 transform: @escaping ( ResponseModel ) -> BusinessModel ) throws {
		self._cache = initialValue
		self._ttl = ttl
		self._fetchData = fetchData
		self._transform = transform
	}

	// MARK: - Public interface

	/**
	Decides whether to fetch new information or to use the cached data.
	Synchronized with any previous call made. Doesn't block the thread from which this is called.

	- parameter ignoreCache:		`true` if the cache TTL should be ignored.
	- parameter completion:			Called with the `data`. Always from `DispatchQueue.main`.
	*/
	public func provideData( ignoreCache: Bool = false, completion: @escaping ( Result<Response<BusinessModel>, Error> ) -> Void ) {
		// Dispatch to our private queue since if multiple calls to the same `DataProvider` are made
		// we don't want to fetch the data multiple times if, for example, 5 calls happen before the 1st one returns and
		// updates the `_cache`.
		_syncQueue.async {
			// Enter the synchronization zone.
			self._semaphore.wait()

			// Check if we can use the cache.
			guard ignoreCache || !self._cache.isValid else {
				return self.handleCachedData( completion: completion )
			}

			// We should either ignore the cache or the cache is not valid anymore.
			self._fetchData { self.handleResponse(result: $0, completion: completion ) }
		}
	}

	// MARK: - Utils.

	/**
	Forwards the `cached data` through the `completion` by wrapping it up in the `Response` model.

	- parameter completion:		Called with the cached data. Called from the `DispatchQueue.main` since the `BusinessModel` can sometimes be `CoreData` model which is sensitive to threads.
	*/
	private func handleCachedData( completion: @escaping ( Result<Response<BusinessModel>, Error> ) -> Void ) {
		// Make sure we're on the main thread. We might be dealing with CoreData objects which are sensible to thread switching.
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { self.handleCachedData( completion: completion ) }
		}

		// The cache is still valid, use it. Forward the model with `isCachedData: true`.
		completion( .success( Response<BusinessModel>( isCachedData: true, model: _cache.value ) ) )

		// Signal the semaphore so other threads can continue execution.
		_semaphore.signal()
	}

	/**
	Handles the data fetch response and calls the `completion` with the appropriate data.
	Will call `transform` if the fetch is successful in order to map the `ResponseModel` to the `BusinessModel`.

	- parameter result:			What we received from the `fetchData` call.
	- parameter completion:		Called with new, valid data or with the error that we've encountered during the `fetchData` process. Called from the `DispatchQueue.main` since the `BusinessModel` can sometimes be `CoreData` model which is sensitive to threads.
	*/
	private func handleResponse( result: Result<ResponseModel, Error>, completion: @escaping ( Result<Response<BusinessModel>, Error> ) -> Void ) {
		// Make sure we're on the main thread. We might be dealing with CoreData objects which are sensible to thread switching.
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { self.handleResponse( result: result, completion: completion ) }
		}

		switch result {
		case .success( let responseModel ):
			do {
				// Map the response models to the ones that we can cache and we can forward.
				let businessModel = try _transform( responseModel )

				// Update the cached values.
				_cache = .init( value: businessModel, timeToLive: _ttl )

				// Forward the success completion with `isCachedData: false`.
				completion( .success( Response<BusinessModel>( isCachedData: false, model: businessModel ) ) )
			} catch {
				// Forward the transformation error.
				completion( .failure( error ) )
			}

		case .failure( let error ):
			// Forward the failure, something has gone wrong.
			completion( .failure( error ) )
		}

		// Signal the semaphore so other threads can continue execution.
		_semaphore.signal()
	}
}
