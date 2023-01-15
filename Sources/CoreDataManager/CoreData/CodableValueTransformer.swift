//
//  CodableValueTransformer.swift
//  Gifts
//
//  Created by Coruț Fabrizio on 19/02/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// The default value transformer used by `CoreData` requires all the models to adhere to NSCoding/ NSSecureCoding.
/// `CodableValueTransformerProtocol` allows us to to avoid the NSCoding/ NSSecureCoding implementation by doing the map/ transform using `Codable` since it's conformance is usually synthesised.
/// Had to use a protocol with an associatedtype instead of a generic class since on iOS 12 and below, CoreData did not know how to use a class that inherits from a generic class
/// hence, making all subclasses not readable from the Objective-C runtime.
/// While it's not that powerful as a generic class, allowing us just to subclass it and specialize the subclass, it still provides some reusability.
public protocol CodableValueTransformerProtocol {
	/// The type of the attribute that we're trying to transform.
	/// Must conform to `Codable`
	associatedtype AttributeType: Codable

	/**
	Encodes the attribute into a representation that `CoreData` can understand.
	e.g. NSNumber, String, Date, URL, Data.

	- parameter value:		The value to encode.
	*/
	func encode( _ value: Any? ) -> Any?

	/**
	Decodes the attribute from the `CoreData` representation.

	- parameter value:		The encoded value.
	*/
	func decode( _ value: Any? ) -> Any?
}

/// Defalut `Codable` implementation.
public extension CodableValueTransformerProtocol {
	func encode( _ value: Any? ) -> Any? {
		// Make sure that the value is of the expected type.
		guard let encodableValue = value as? AttributeType else { return nil }

		// Encode the value into data.
		return try? JSONEncoder().encode( encodableValue )
	}

	func decode( _ value: Any? ) -> Any? {
		// Make sure that what we're about to decode is Data from which we can decode our object.
		guard let valueData = value as? Data else { return nil }

		// Decode the data into the expected value
		return try? JSONDecoder().decode( AttributeType.self, from: valueData )
	}
}
