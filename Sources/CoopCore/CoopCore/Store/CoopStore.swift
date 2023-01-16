//
//  CoopStore.swift
//  CoopModels
//
//  Created by Coruț Fabrizio on 14/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation
import MapKit
import CoreData

// TODO: Move this model to separate module -IZ
public final class CoopStore: NSObject, Codable {

	struct StoreLocation: Decodable {
		let coordinates: [CLLocationDegrees]
	}

	// MARK: - Properties.

	/// Kardex ID. Unique identifier of the store.
	public let kardexID: Int

	/// Store ID - store ID is a (maximum) 4 digit number (as opposed to the 5 digit kardex ID).
	public let storeID: Int?

	/// Name of the store.
	public let name: String

	// CoopStore specific information.
	public let address: String
	public let city: String
	public let postalCode: String
	public let phoneNumber: String?

	// Coordinates
	public let latitude: CLLocationDegrees
	public let longitude: CLLocationDegrees

	/// `true` if the `latitude` and `longitude` are still valid.
	public let coordinatesValid: Bool

	/// The `brand` that the store represents.
	public let brand: Brand

	/// Schedule of the store.
	public let openingHours: [OpeningHours]

	/// `true` if the store has `SelfScanning` machines installed in it.
	public let isSelfScanningEnabled: Bool

	/// Custom description override. Will contain the `name` and `kardexID`.
	public override var description: String {
		return "Store \(name) (\(kardexID))"
	}

	public override var hash: Int {
		return kardexID.hashValue
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container( keyedBy: AnyKey.self )
		kardexID = try container.decode( keys: [Keys.kardexID, AlternativeKeys.kardexID, CodingKeys.kardexID] )
		name = try container.decode( keys: [Keys.name, AlternativeKeys.name, CodingKeys.name] )

		if let isSelfScanningEnabled: Bool = container.decodeIfPresent( keys: [Keys.isSelfScanningEnabled, AlternativeKeys.isSelfScanningEnabled, CodingKeys.isSelfScanningEnabled] ) {
			self.isSelfScanningEnabled = isSelfScanningEnabled
		} else {
			self.isSelfScanningEnabled = false
		}

		// If these fields are missing, they will be set to empty string.
		address = container.decodeIfPresent( keys: [Keys.address, AlternativeKeys.address, CodingKeys.address] ) ?? ""
		city = container.decodeIfPresent( keys: [Keys.city, AlternativeKeys.city, CodingKeys.city] ) ?? ""
		if let postalCode: String = container.decodeIfPresent( keys: [Keys.postalCode, AlternativeKeys.postalCode, CodingKeys.postalCode] )  {
			self.postalCode = postalCode
		} else if let postalCodeNumber: Int = container.decodeIfPresent( keys: [Keys.postalCode, AlternativeKeys.postalCode, CodingKeys.postalCode] ) {
			postalCode = String( postalCodeNumber )
		} else {
			postalCode = ""
		}

		storeID = container.decodeIfPresent( keys: [Keys.storeID, AlternativeKeys.storeID, CodingKeys.storeID] )

		// Phone can be nil
		phoneNumber = container.decodeIfPresent( keys: [Keys.phoneNumber, AlternativeKeys.phoneNumber, CodingKeys.phoneNumber] )

		if let location: StoreLocation = container.decodeIfPresent( keys: [Keys.location, AlternativeKeys.location] ) {
			self.latitude = location.coordinates[ 1 ]
			self.longitude = location.coordinates[ 0 ]
			self.coordinatesValid = true
		} else if let latitude: CLLocationDegrees = container.decodeIfPresent( keys: [CodingKeys.latitude] ),
				  let longitude: CLLocationDegrees = container.decodeIfPresent( keys: [CodingKeys.longitude] ) {
			self.latitude = latitude
			self.longitude = longitude
			self.coordinatesValid = true
		} else {
			self.latitude = 0
			self.longitude = 0
			self.coordinatesValid = false
		}

		if let brandString: String = container.decodeIfPresent( keys: [Keys.brand, AlternativeKeys.brand, CodingKeys.brand] ), let brand = Brand( JSONString: brandString, storeName: self.name ) {
			self.brand = brand
		} else {
			self.brand = .unknown
		}

		// Opening hours
		openingHours = container.decodeIfPresent( keys: [Keys.openingHours, AlternativeKeys.openingHours, CodingKeys.openingHours] ) ?? []
	}
}
