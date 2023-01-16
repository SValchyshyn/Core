//
//  CoopStore+Keys.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 17/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

extension CoopStore {
	/// Keys used to parse the JSON representation of the CoopStore.
	enum Keys: String, CodingKey {
		case kardexID = "K"
		case storeID = "S"
		case name = "N"
		case address = "A"
		case location = "L"
		case brand = "R"
		case city = "C"
		case postalCode = "Z"
		case phoneNumber = "P"
		case coordinates = "coordinates"
		case openingHours = "O"
		case openingHoursDay = "Day"
		case openingHoursFromDate = "FromDate"
		case openingHoursToDate = "ToDate"
		case openingHoursText = "Text"
		case isSelfScanningEnabled = "B"
	}

	/// Alternative keys that can also be used to parse the JSON representation.
	enum AlternativeKeys: String, CodingKey {
		case kardexID = "Kardex"
		case storeID = "StoreId"
		case name = "Name"
		case address = "Address"
		case location = "Location"
		case brand = "RetailGroupName"
		case city = "City"
		case postalCode = "Zipcode"
		case phoneNumber = "Phonenumber"
		case openingHours = "OpeningHours"
		case isSelfScanningEnabled = "BipAndPay"
	}

	/**
	The coding keys used in the older version of the app. We need them in order to ensure that we can still decode the objects encoded with these keys.
	They are also used for default encoding.
	*/
	enum CodingKeys: String, CodingKey {
		case kardexID
		case storeID
		case name
		case address
		case city
		case postalCode
		case phoneNumber
		case latitude
		case longitude
		case coordinatesValid
		case brand
		case openingHours
		case isSelfScanningEnabled
	}
}
