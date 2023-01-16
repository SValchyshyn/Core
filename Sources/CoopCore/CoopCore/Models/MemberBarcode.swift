//
//  MemberBarcode.swift
//  CoopCore
//
//  Created by Andriy Tkach on 11/12/20.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

public struct MemberBarcode: Codable {
	public var memberNumber: Int
	public var barcode: String
	public var statusCode: String
}
