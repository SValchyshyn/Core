//
//  Optional+String.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 18.03.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

public extension Optional where Wrapped == String {

	/// Same functionality as `.map` but also makes sure that the value provided in the `transform` is `.isEmpty == false`.
	/// - Parameter transform: Used to perform transformations on the `Wrapped` value.
	func mapNotEmpty<Result>( transform: (Wrapped) -> Result ) -> Result? {
		switch self {
		case .some( let value ) where !value.isEmpty:
			return transform( value )

		default:
			return nil
		}
	}
}
