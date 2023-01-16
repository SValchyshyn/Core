//
//  Hasher+combineValues.swift
//  CoopCore
//
//  Created by Nazariy Vlizlo on 26.03.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

public extension Hasher {
	mutating func combine<H>( values: H... ) where H: Hashable {
		values.forEach { combine($0) }
	}
}
