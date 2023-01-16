//
//  Instantiatable.swift
//  CoopCore
//
//  Created by Valeriy Kolodiy on 24.12.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// The protocol that is used to define the common interface for instantiation logic while working with different types
public protocol Instantiatable {
	/// Returns instantiated instance of the conforming type
	static func instantiate() -> Self
}
