//
//  CodingValueTransformer.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 02/11/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public final class CodingValueTransformer<T: NSSecureCoding & NSObject>: ValueTransformer {

	public override class func transformedValueClass() -> AnyClass {
		return T.self
	}

	public override class func allowsReverseTransformation() -> Bool {
		return true
	}

	// MARK: - ValueTransformer.

	public override func transformedValue( _ value: Any? ) -> Any? {
		guard let value = value as? T else { return nil }
		return try? NSKeyedArchiver.archivedData( withRootObject: value, requiringSecureCoding: true )
	}

	public override func reverseTransformedValue( _ value: Any? ) -> Any? {
		guard let data = value as? NSData else { return nil }
		return try? NSKeyedUnarchiver.unarchivedObject( ofClass: T.self, from: data as Data )
	}

	// MARK: - Helper static acess.

	/// The name of this transformer. This is the name used to
	/// register the transformer using
	/// `ValueTransformer.setValueTransformer(_:forName:)`
	public static var transformerName: NSValueTransformerName {
		// we append the Transformer due easily identify.
		// Example. Clase name UserSetting then the name
		// of the transformer is UserSettingTransformer
		return NSValueTransformerName( "\(String( describing: T.self ))Transformer" )
	}

	/// Registers the transformer by calling
	/// `ValueTransformer.setValueTransformer(_:forName:)`.
	public static func registerTransformer() {
		ValueTransformer.setValueTransformer( CodingValueTransformer<T>(), forName: transformerName )
	}
}
