//
//  NSSecureCoding+keychain.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 26.10.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

extension NSSecureCoding where Self: NSObject {

	/// Creates a new instance from an `encoded raw representation`. The `raw representation` should be the result of `Self.keychainEncoded(_:)`.
	/// - Parameter data: The `raw Data` to which the instance has been represented.
	/// - Throws: Unarchiving errors.
	public static func keychainDecoded( from data: Data ) throws -> Self? {
		try NSKeyedUnarchiver.unarchivedObject( ofClass: Self.self, from: data )
	}
	
	/// Serializes an instance of `Self` to a `raw representation`.
	/// - Parameter object: The instance that it's about to be archived.
	/// - Throws: Archive errors.
	public static func keychainEncoded( _ object: Self ) throws -> Data {
		try NSKeyedArchiver.archivedData( withRootObject: object, requiringSecureCoding: true )
	}
}

extension Array where Element: NSObject {
	
	/// Creates a new instance from an `encoded raw representation`. The `raw representation` should be the result of `Self.keychainEncoded(_:)`.
	/// - Parameter data: The `raw Data` to which the instance has been represented.
	/// - Throws: Unarchiving errors.
	public static func keychainDecoded( from data: Data ) throws -> Self? {
		// Arrays cannot be unarchived as Array since it does not conform to NSObject. We need to workaround this using NSArray.
		try NSKeyedUnarchiver.unarchivedObject( ofClasses: [NSArray.self, Element.self], from: data ) as? Self
	}
	
	/// Serializes an instance of `Self` to a `raw representation`.
	/// - Parameter object: The instance that it's about to be archived.
	/// - Throws: Archive errors.
	public static func keychainEncoded( _ object: Self ) throws -> Data {
		try NSKeyedArchiver.archivedData( withRootObject: object, requiringSecureCoding: true )
	}
}
