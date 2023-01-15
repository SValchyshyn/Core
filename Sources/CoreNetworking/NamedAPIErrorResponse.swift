//
//  PosErrorResponse.swift
//  POSCheckin
//
//  Created by Nazariy Vlizlo on 15.10.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import Foundation

public struct NamedAPIErrorResponse: Decodable {
	public let name: String
	public let message: String
	
	public static func initFrom( data: Data ) -> NamedAPIErrorResponse? {
		let decoder = JSONDecoder()
		return try? decoder.decode( self, from: data )
	}
}
