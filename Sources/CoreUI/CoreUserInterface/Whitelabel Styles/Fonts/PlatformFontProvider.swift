//
//  PlatformFontProvider.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 08.04.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

/// Platform specific `PlatformFontStyle` used throughout the whitelabeled features.
public enum PlatformFontStyle: FontStyle {

	/// Platform specific `FontSizeType`. Defines the sizes of fonts in an abstract way so we can keep them consistent and agnostic.
	public enum PlatformFontSizeType: CGFloat {

		/// Associated with a size of `18 pts`.
		case title = 18

		/// Associated with a size of `16 pts`.
		case subtitle = 16

		/// Associated with a size of `14 pts`.
		case body = 14

		/// Associated with a size of `12 pts`.
		case caption = 12
		
		/// Associated with a size of `10 pts`.
		case small = 10
	}

	/// The `light` weigth variation of a font.
	case light( _ sizeType: PlatformFontSizeType )

	/// The `regular` weigth variation of a font.
	case regular( _ sizeType: PlatformFontSizeType )

	/// The `medium` weigth variation of a font.
	case medium( _ sizeType: PlatformFontSizeType )

	/// The `semibold` weigth variation of a font.
	case semibold( _ sizeType: PlatformFontSizeType )

	/// The `bold` weigth variation of a font.
	case bold( _ sizeType: PlatformFontSizeType )
	
	/// The `heavy` weigth variation of a font.
	case heavy( _ sizeType: PlatformFontSizeType )
}

/// Should serve as the base inheritance for **all** the font specialization protocols in the whitelabeling solutions.
open class BasePlatformFontProvider: FontProvider<PlatformFontStyle> { }

/// Specialied `FontProvider` that relies on `PlatformFontResolver` subclasses as concrete providers.
public protocol PlatformFontProvider: BasePlatformFontProvider {

	// swiftlint:enable:this identifier_name
	/// Font specific for `H1 headers`.
	var H1HeaderFont: UIFont { get }

	/// Font specific for `H2 headers`.
	var H2HeaderFont: UIFont { get }

	/// Font specific for `H3 headers`.
	var H3HeaderFont: UIFont { get }

	/// Font specific for `H3 headers` but with `.light` weigth.
	var H3LightFont: UIFont { get }

	/// Font specific for `H4 headers`.
	var H4HeaderFont: UIFont { get }

	/// Font specific for `H5 headers`.
	var H5HeaderFont: UIFont { get }

	/// Font specific for `H6 headers`.
	var H6HeaderFont: UIFont { get }

	/// Font specific for large `phone numbers`.
	var phoneNumberFont: UIFont { get }

	/// Font specific for usage with labels that contain `URLs`.
	var linkFont: UIFont { get }

	/// Font specific to the feed date of publication label.
	var feedDateFont: UIFont { get }

	/// Font specific to labels using `superscrip` values which should usually be bigger than the normal, consistent font.
	var superscriptFont: UIFont { get }

	/// Font specific to labels expressing `amounts` of objects. e.g. currency
	var amountLargeFont: UIFont { get }

	/// Font specific to labels expressing `amounts` of objects, but in larger display. e.g. currency
	var amountHugeFont: UIFont { get }
	
	/// Font specific to the items from tab bars.
	var tabBarFont: UIFont { get }
}
