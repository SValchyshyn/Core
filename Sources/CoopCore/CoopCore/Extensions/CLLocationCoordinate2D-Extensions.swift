//
//  CLLocationCoordinate2D-Extensions.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 06/04/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import CoreLocation

/// Extension allowing coordinates to be decoded from JSON.
extension CLLocationCoordinate2D: Decodable {
	public enum CodingKeys: String, CodingKey {
		  case latitude
		  case longitude
	}

	public init( from decoder: Decoder ) throws {
		self.init()

		let values = try decoder.container( keyedBy: CodingKeys.self )
		latitude = try values.decode( Double.self, forKey: .latitude )
		longitude = try values.decode( Double.self, forKey: .longitude )
	}
}
