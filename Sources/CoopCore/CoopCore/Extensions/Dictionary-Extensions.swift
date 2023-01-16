//
//  Dictionary-Extensions.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 16/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

public extension Dictionary where Key == String {
	/**
	A function for accessing a value with multiple possible keys.
	*/
	func valueFor( keys: [String] ) -> Any? {
		guard let key = keys.first( where: { self[$0] != nil } ) else { return nil }
		return self[key]
	}

	/// Convenience way of accessing values through type safetly.
	subscript<U: RawRepresentable>( _ stringRawRepresentable: U ) -> Value? where U.RawValue == String {
		return self[ stringRawRepresentable.rawValue ]
	}
}
