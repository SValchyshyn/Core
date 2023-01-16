//
//  Mappers.swift
//  Stores
//
//  Created by Stepan Valchyshyn on 06.08.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

extension StoreData {

	public enum Constants {

		/// Default value for `Chains` which do not use the `.rank` property.
		public static let defaultKardexId: Int = NSNotFound
	}

	func mapToDomain() -> Store {
		return .init(
			id: id,
			kardexId: Constants.defaultKardexId, // Not used in the platform concept. Legacy.
			name: name,
			isSelfScanningEnabled: true, // Not received from the backend yet.
			location: location?.mapToDomain(),
			chain: chain.mapToDomain(),
			openingHours: [], // Not received from the backend yet.
			contact: contactInfo?.mapToDomain(),
			status: status,
			type: type
		)
	}
}

extension LocationData {
	func mapToDomain() -> Store.Location {
		return Store.Location( country: country, city: city, street: street, streetNumber: streetNumber, postalCode: postalCode, coordinates: coordinates?.mapToDomain() )
	}
}

extension CoordinatesData {
	func mapToDomain() -> Store.Coordinates {
		return .init( latitude: latitude, longitude: longitude )
	}
}

extension ChainData {
	
	public enum Constants {

		/// Default value for `Chains` which do not use the `.rank` property.
		public static let defaultRank: Int = NSNotFound
	}

	func mapToDomain() -> Chain {
		return .init(
			id: id,
			name: name,
			colorHexString: color,
			rank: Constants.defaultRank, // Not used in the platform concept. Legacy.
			logoURLString: logoUrl,
			logoWhiteURLString: logoWhiteUrl,
			pinIconURLString: pinIconUrl,
			largeLogoURLString: nil,
			aliasLogoURLString: logoAliasUrl,
			filterURLString: nil
		)
	}
}

extension ContactInfoData {
	func mapToDomain() -> Store.ContactInfo {
		return .init( phoneNumber: phoneNumber, email: email )
	}
}
