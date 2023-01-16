//
//  Filter.swift
//  CoopModels
//
//  Created by Coruț Fabrizio on 16/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation
import MapKit

extension CoopStore {
	public enum Filter: Encodable, Hashable {
		private enum CodingKeys: String, CodingKey {
			case type = "Type"
			case lat = "Lat"
			case lng = "Lon"
			case distance = "Distance"
			case kardexNumbers = "KardexNumbers"
			case retailGroups = "RetailGroups"
			case isBipAndPay = "IsBipAndPay"
		}

		/// Filter by location within a given distance from a coordinate (latitude and longitude)
		case location( distance: Int, coordinate: CLLocationCoordinate2D )

		/// Filter by kardex number(s) - pass this to the filter function to only return stores with the given kardex numbers
		case kardex( kardexNumbers: [ Int ] )

		/// Filter by retail groups
		case retailGroup( stores: [ CoopStore.Brand ] )

		var type: String {
			switch self {
			case .location:
				return "Radius"

			case .kardex:
				return "Kardex"

			case .retailGroup:
				return "RetailGroup"
			}
		}

		public func encode( to encoder: Encoder ) throws {
			var container = encoder.container( keyedBy: CodingKeys.self )
			try container.encode( type, forKey: .type )

			switch self {
			case let .location( distance, coordinate ):
				try container.encode( distance, forKey: .distance )

				// Get the latitude and longitude and encode them with 7 decimals
				let latString = String( format: "%.7f", coordinate.latitude )
				let lngString = String( format: "%.7f", coordinate.longitude )
				try container.encode( latString, forKey: .lat )
				try container.encode( lngString, forKey: .lng )

			case let .kardex( kardexNumbers ):
				try container.encode( kardexNumbers, forKey: .kardexNumbers )

			case let .retailGroup( stores ):
				var storesString: [ String ] = stores.map {
					if $0 == .dagliBrugsen {
						// dagliBrugsen has specific case
						return "dagli'brugsen"
					} else {
						// Otherwise, we can use the rawValue
						return $0.rawValue
					}
				}
				
				// Add fakta chain if user wants to have coop365 results as it's the same chain id on backend
				if stores.contains(.coop365) {
					storesString.append("fakta")
				}
				
				try container.encode( storesString, forKey: .retailGroups )
			}
		}

		// MARK: - Hashable

		/// NOTE: The hashValue is very naively computed, but it fulfills its purpose: We implement `Hashable` in order to ensure, that all cases are not added more than once.
		public func hash( into hasher: inout Hasher ) {
			switch self {
			case .location:
				hasher.combine( 0 )

			case .kardex:
				hasher.combine( 2 )

			case .retailGroup:
				hasher.combine( 3 )
			}
		}

		public static func == ( lhs: Filter, rhs: Filter ) -> Bool {
			return lhs.hashValue == rhs.hashValue
		}
	}

	public struct StoreFilters: Encodable {
		private enum CodingKeys: String, CodingKey {
			case filters = "Filters"
		}

		/// The filters to apply to the search - this is a set, in order not to create invalid JSON post data.
		let filters: Set<Filter>

		public init(filters: Set<Filter>) {
			self.filters = filters
		}
		
		public func encode( to encoder: Encoder ) throws {
			var container = encoder.container( keyedBy: CodingKeys.self )
			try container.encode( filters, forKey: .filters )
		}
	}
}
