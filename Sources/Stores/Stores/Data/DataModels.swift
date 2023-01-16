//
//  Models.swift
//  Stores
//
//  Created by Stepan Valchyshyn on 06.08.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

struct StoreData: Decodable {
	public let id: String
	public let name: String
	public let location: LocationData?
	public let chain: ChainData
	public let contactInfo: ContactInfoData?
	public let status: StoreStatus?
	public let type: StoreType?
	
	enum CodingKeys: String, CodingKey {
		 case id, name, location, chain, contactInfo, status, type
	}
	
	public init (from decoder: Decoder) throws {
		let container =  try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		name = try container.decode(String.self, forKey: .name)
		location = try container.decodeIfPresent(LocationData.self, forKey: .location)
		chain = try container.decode(ChainData.self, forKey: .chain)
		contactInfo = try container.decodeIfPresent(ContactInfoData.self, forKey: .contactInfo)
		status = try? container.decodeIfPresent(StoreStatus.self, forKey: .status)
		type = try? container.decodeIfPresent(StoreType.self, forKey: .type)
	}
}

struct ContactInfoData: Decodable {
	private enum CodingKeys: String, CodingKey {
		case phoneNumber = "phone"
		case email
	}

	public let phoneNumber: String?
	public let email: String?
}

struct LocationData: Decodable {
	private enum CodingKeys: String, CodingKey {
		case country
		case city
		case street
		case streetNumber
		case postalCode
		case coordinates = "geoCoordinates"
	}
	
	public let country: String?
	public let city: String?
	public let street: String?
	public let streetNumber: String?
	public let postalCode: String?
	public let coordinates: CoordinatesData?
}

struct CoordinatesData: Decodable {
	public let latitude: Double
	public let longitude: Double
}

struct ChainData: Decodable {
	public let id: String
	public let name: String
	public let color: String?
	public let logoUrl: String?
	public let logoWhiteUrl: String?
	public let logoAliasUrl: String?
	public let pinIconUrl: String?
}
