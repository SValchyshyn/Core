//
//  AttributedPriceBuilder.swift
//  CoreUserInterface
//
//  Created by Marian Hunchak on 20.08.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit
import CoreNetworking

class AttributedPriceBuilder {
	
	private enum Constants {
		static let subscriptFontRatio: CGFloat = 0.5
		static let subscriptOffsetRatio: CGFloat = 0.35
	}

	private let attributedString = NSMutableAttributedString()
	private let defaultAttributes: [NSAttributedString.Key: Any]
	
	private let config: DefaultPriceConfiguration
	
	init( config: DefaultPriceConfiguration ) {
		self.config = config
		self.defaultAttributes = [.font: config.fontType.font]
	}
	
	func getAttributedPrice() -> NSAttributedString {
		return attributedString
	}
	
	func getAmountString(from amount: Double) -> String? {
		let numberFormatter = String.priceStringFormatter
		numberFormatter.decimalSeparator = config.decimalSeparator.rawValue
		numberFormatter.groupingSeparator = config.groupingSeparator.rawValue
		
		switch config.rounding {
		case .none:
			break
			
		case .removeTrailingZeroes:
			numberFormatter.minimumFractionDigits = 0
			numberFormatter.maximumFractionDigits = 2
		}
		
		return numberFormatter.string( from: NSNumber( value: amount ) )
	}
	
	func getIntegerAndDecimalPart(from amountString: String) -> (String, String) {
		let components = amountString.components( separatedBy: config.decimalSeparator.rawValue )
		
		let integerPart = components.first ?? ""
		let decimalPart = components.count == 2 ? components[1] : ""
		
		return (integerPart, decimalPart)
	}
	
	func addIntegerPart( _ string: String ) {
		attributedString.append( NSAttributedString( string: string, attributes: defaultAttributes ) )
	}
	
	func addDecimalPart( _ string: String ) {
		if !string.isEmpty {
			// Add decimal separator only if we have decimal part
			addDecimalSeparator()
		}
		
		let decimalAttributes = config.decimalType == .small ? attributes( for: config.decimalGravity ) : defaultAttributes
		let decimalPart = NSAttributedString( string: string, attributes: decimalAttributes )
		attributedString.append( decimalPart )
	}
	
	func addSymbol() {
		guard !config.symbol.isEmpty else { return }
		
		// Add space after symbol if symbol is at the beginning, otherwise add space before symbol
		var symbol = config.symbolLayout.position == .start ? "\(config.symbol) " : " \(config.symbol)"
		// Apply capitalization type
		symbol = config.symbolLayout.capitalization.cast( symbol )
		
		let symbolAttributes = attributes( for: config.symbolLayout.gravity )
		let attributed = NSAttributedString( string: symbol, attributes: symbolAttributes )
		config.symbolLayout.position == .start ? attributedString.insert( attributed, at: 0 ) : attributedString.append( attributed )
	}
	
	private func addDecimalSeparator() {
		guard config.decimalType == .normal else { return }
		let attributed = NSAttributedString( string: config.decimalSeparator.rawValue, attributes: defaultAttributes )
		attributedString.append( attributed )
	}
	
	private func attributes( for gravity: Gravity ) -> [NSAttributedString.Key: Any] {
		let subscriptedFont = config.fontType.font.withSize( config.fontSize * Constants.subscriptFontRatio )
		
		switch gravity {
		case .top:
			let subscriptOffset = config.fontSize * Constants.subscriptOffsetRatio
			return [.font: subscriptedFont, .baselineOffset: subscriptOffset]
			
		case .bottom:
			return [.font: subscriptedFont]
			
		case .center:
			return defaultAttributes
		}
	}
}
