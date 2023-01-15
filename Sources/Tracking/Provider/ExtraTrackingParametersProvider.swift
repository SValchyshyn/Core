//
//  ExtraTrackingParametersProvider.swift
//  Tracking
//
//  Created by Coruț Fabrizio on 18/03/2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

/// Creates an interface through which the tracking process can be enriched with information in a decoupled way.
public protocol ExtraTrackingParametersProvider: NSObject {
	/// Extra parameters added in the tracking events.
	var parameters: [Tracking.Parameter] { get }
}

/// Type erasing wrapper used for `ExtraTrackingParametersProvider` which can also be `Hashable`.
final class AnyExtraTrackingParametersProvider: Hashable {
	/// The actual provider.
	let provider: ExtraTrackingParametersProvider

	/// Extra parameters added in the tracking events.
	var parameters: [Tracking.Parameter] {
		return provider.parameters
	}

	init( _ provider: ExtraTrackingParametersProvider ) {
		self.provider = provider
	}

	// MARK: - Hashable conformance.

	static func == ( lhs: AnyExtraTrackingParametersProvider, rhs: AnyExtraTrackingParametersProvider ) -> Bool {
		// Since it's a wrapper object, use the underlying value to compare equality.
		// Consider them equal if they're the same instance.
		return lhs.provider === rhs.provider
	}

	func hash( into hasher: inout Hasher ) {
		provider.hash( into: &hasher )
	}
}
