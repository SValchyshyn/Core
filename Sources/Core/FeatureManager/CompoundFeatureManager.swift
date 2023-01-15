//
//  CompoundFeatureManager.swift
//  Core
//
//  Created by Marian Hunchak on 08.09.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import OrderedCollections
import Dispatch
import Foundation

open class CompoundFeatureManager: FeatureManager {
	
	// MARK: - Properties
	
	/// Allows centralization of feature handling. Use `OrderedDictionary` for the situation in which we're adding two
	/// `FeatureManager` that provide resolution for the same underlying `Feature`, the look-up will always be deterministic.
	public let featureManagers: OrderedDictionary<String, FeatureManager>

	// MARK: - Init
	
	public init( managers: FeatureManager... ) {
		self.featureManagers = managers.reduce( into: [:], { acc, manager in
			acc[manager.identifier] = manager
		} )
	}
	
	// MARK: - FeatureManager protocol conformance
	
	public var hasCacheAvailable: Bool {
		featureManagers.reduce( true, { $1.value.hasCacheAvailable && $0 } )
	}
	
	public func setup( extraConfiguration: [String: Any]?, completion: @escaping ( _ isReady: Bool ) -> Void ) {
		// Synchronize the setup of all the managers.
		let group: DispatchGroup = .init()
		
		// Adopt an all or nothing strategy when determining the readiness of the FeatureManager.
		let isReady: AtomicValue<Bool> = true
		featureManagers.forEach {
			group.enter()
			$0.value.setup( extraConfiguration: extraConfiguration ) { localReady in
				// Make sure no two threads can access the isReady variable.
				isReady.compareExchange( expected: true, desired: localReady )
			
				// Signal the setup ending.
				group.leave()
			}
		}
		
		// Wait for all of them to finish before calling the completion.
		group.notify( queue: .main ) {
			completion( isReady.wrappedValue )
		}
	}
	
	public func clearTreatmentData( completion: (() -> Void)? = nil ) {
		let group: DispatchGroup = .init()
		// Perform a clean-up on all the internal managers and wait for all of them to finish.
		featureManagers.forEach { group.enter(); $0.value.clearTreatmentData { group.leave() } }
		group.notify( queue: .main, execute: completion ?? { } )
	}
		
	public func getTreatment( for feature: Feature, attributes: [String: Any] ) -> FeatureStatus? {
		featureManagers.values
			// Mark it as lazy so we do not actually iterate over the whole sequence.
			.lazy
			// Make sure we have a valid treatment value.
			.compactMap { $0.getTreatment(for: feature, attributes: attributes) }
			// We're only interested in the first valid value.
			.first
	}
	
	public func getConfiguration<T>( for feature: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil ) -> T? where T: Decodable {
		featureManagers.values
			// Mark it as lazy so we do not actually iterate over the whole sequence.
			.lazy
			// Make sure we have a valid configuration value.
			.compactMap { $0.getConfiguration(for: feature, dateDecodingStrategy: dateDecodingStrategy ) }
			// We're only interested in the first valid value.
			.first
	}
}
