//
//  DefaultPriceConfiguration.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 09.09.2021.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import UIKit

public protocol DefaultPriceConfiguration: PriceConfiguration {
	var fontType: FontType { get set }
	var decimalSeparator: Separator { get set }
	var groupingSeparator: Separator { get set }
	var symbolLayout: SymbolLayout { get set }
	var decimalGravity: Gravity { get set }
	var rounding: Rounding { get set }
	var symbolFont: UIFont? { get }
	var decimalFont: UIFont? { get }
	
	func getAttributedPrice( from amount: Double ) -> NSAttributedString?
}

public extension DefaultPriceConfiguration {
	var symbolFont: UIFont? {
		// This font is optional
		return nil
	}
	
	var decimalFont: UIFont? {
		// This font is optional
		return nil
	}
	
	var fontSize: CGFloat {
		get { fontType.font.pointSize }
		set { fontType = .custom( fontType.font.withSize( newValue ) ) }
	}
	
	func getAttributedPrice( from amount: Double ) -> NSAttributedString? {
		let builder = AttributedPriceBuilder( config: self )
		
		guard let amountString = builder.getAmountString( from: amount ) else { return nil }
		let (integerPart, decimalPart) = builder.getIntegerAndDecimalPart( from: amountString )
		
		builder.addIntegerPart( integerPart )
		builder.addDecimalPart( decimalPart )
		builder.addSymbol()
		
		return builder.getAttributedPrice()
	}
}

public typealias SymbolLayout = (position: Position, gravity: Gravity, capitalization: CapitalizationType)

/// Set decimal or amount separator
public enum Separator: String {
	case comma = ","
	case dot = "."
}

/// Configures whether symbol should be at the beginning or at the end of string
public enum Position {
	case start
	case end
}

/// Configures Symbol or DecimalPart vertical position inside attributet string.
public enum Gravity {
	case top
	case center
	case bottom
}

/// Configures the amount with one of the rounding strategies.
public enum Rounding {
	case none
	/// Remove trailing zeroes from decimal part.
	case removeTrailingZeroes
}

/// Configures Symbol with a capitalization style
public enum CapitalizationType {
	case capitalize
	case uppercase
	case lowercase
	
	func cast( _ currency: String ) -> String {
		switch self {
		case .capitalize:
			return currency.capitalized
			
		case .uppercase:
			return currency.uppercased()
			
		case .lowercase:
			return currency.lowercased()
		}
	}
}

public enum FontType {
	case large
	case huge
	case custom( UIFont )
	
	var font: UIFont {
		switch self {
		case .large:                return fontProvider.amountLargeFont
		case .huge:                 return fontProvider.amountHugeFont
		case .custom( let font ):   return font
		}
	}
}
