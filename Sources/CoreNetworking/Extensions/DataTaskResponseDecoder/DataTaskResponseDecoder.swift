//
//  DataTaskResponseDecoder.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 18.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

/// Decodes data into response.
protocol DataTaskResponseDecoder {
	
	associatedtype Response
	
	func decode(data: Data) async throws -> Response
	
}
