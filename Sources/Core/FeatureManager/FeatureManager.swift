//
//  SplitManager.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 20/11/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

// Wiki page describing Features and FeatureManager is available here - https://dev.azure.com/loopbycoop/Samkaup/_wiki/wikis/Samkaup.wiki/110/Features-and-FeatureManager
/**
Protocol to comfort feature registry to. `Identifier` is used to fetch a treatment.
*/
public protocol Feature {
	var identifier: String { get }
}

public extension Feature where Self: RawRepresentable, RawValue == String {
	/// Default identifier implementation from rawValue
	var identifier: String { rawValue }
}

/**
Observer that is called every time a remote feature flag status is accessed.
*/
public protocol FeatureFlagsObserver {
	/**
	The app has accessed a flag with the given identifier and the given value was returned.
	**Important:** This function can be called very often. Do not perform any performance intensive work as a result of it being called.
	*/
	func remoteFeatureFlagAccessed( value: String?, for identifier: String )
}

public protocol FeatureFlagObservable {
	/**
	Register the given observer with the features manager
	*/
	func registerFeatureFlagsObserver( observer: FeatureFlagsObserver )
}

public protocol FeatureManager {

	/// Uniquely identifies the `Resolver`.
	var identifier: String { get }
	
	/// Indicates wether `FeatureManager` has cached data available
	var hasCacheAvailable: Bool { get }

	/// Configure your dependencies here
	/// - Parameters:
	///   - extraConfiguration: Configuration dictionary. For example `userType`: regular, freemium, etc
	///   - completion: A completion callback
	func setup( extraConfiguration: [String: Any]?, completion: @escaping ( _ isReady: Bool ) -> Void )

	/// Cleans cached treatment data
	/// - Parameter completion: Completion handler called after data removal. Defaults to `nil`
	func clearTreatmentData( completion: (() -> Void)? )

	/// Get the treatment (status) for the given feature
	/// - Parameter feature: Feature for which to fetch the status/treatment
	func getTreatment( for feature: Feature ) -> FeatureStatus?

	/// Get the treatment (status) for the given feature
	/// - Parameters:
	///   - feature: Feature for which to fetch the status/treatment
	///   - attributes: An optional map of parameters we can send to feature service
	func getTreatment( for feature: Feature, attributes: [String: Any] ) -> FeatureStatus?

	/// Get the remote configuration.
	/// - Parameters:
	///   - feature: The name of the feature for which we're fetching the treatment.
	///   - dateDecodingStrategy: Used when decoding the treatment, if that contains any dates. Defaults to `nil`.
	func getConfiguration<T: Decodable>( for feature: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? ) -> T?
}

public extension FeatureManager {

	func getTreatment( for feature: Feature ) -> FeatureStatus? {
		getTreatment( for: feature, attributes: [:] )
	}
	
	/// Default implementation that will use the class name as an identifier.
	var identifier: String { .init( describing: Self.self ) }
}
