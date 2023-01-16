//
//  Store+Coordinates.swift
//  Stores
//
//  Created by Coruț Fabrizio on 18.05.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation

public extension Store {

	/// Contains information used to position the `Store` on a map.
	struct Coordinates {

		// MARK: - Properties.

		public let latitude: Double
		public let longitude: Double

		// MARK: - Init

		public init( latitude: Double, longitude: Double ) {
			self.latitude = latitude
			self.longitude = longitude
		}
	}
}
