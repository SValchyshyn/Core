//
//  URLQueryItem-Extensions.swift
//  CoopCore
//
//  Created by Andriy Tkach on 3/29/22.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public extension Sequence where Element == URLQueryItem {
	subscript(key: String) -> String? {
		first { $0.name.lowercased() == key.lowercased() }?.value
	}
}
