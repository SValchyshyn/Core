//
//  MonetaryValueTransformer.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 25/05/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// Used for `Transformable type Attributes` defined in CoreData `.xcdatamodel`.
/// The `ValueTransformer` is used to map/ transform a model to another memory representation, equivalent or not. e.g. we want the property as an `URL` but we want to store it in CoreData as a `String`.
/// For more documentation: https://developer.apple.com/documentation/foundation/valuetransformer
/// Specialize the `CodableValueTransformer` for an array of `Voucher.StoreModel`
@objc(MonetaryValueTransformer)
final class MonetaryValueTransformer: ValueTransformer, CodableValueTransformerProtocol {
	typealias AttributeType = MonetaryValue

	override class func allowsReverseTransformation() -> Bool {
		return true
	}

	override func transformedValue( _ value: Any? ) -> Any? {
		return encode( value )
	}

	override func reverseTransformedValue( _ value: Any? ) -> Any? {
		return decode( value )
	}
}

@objc(BonusMonetaryValueTransformer)
final class BonusMonetaryValueTransformer: ValueTransformer, CodableValueTransformerProtocol {
	typealias AttributeType = BonusMonetaryValue

	override class func allowsReverseTransformation() -> Bool {
		return true
	}

	override func transformedValue( _ value: Any? ) -> Any? {
		return encode( value )
	}

	override func reverseTransformedValue( _ value: Any? ) -> Any? {
		return decode( value )
	}
}
