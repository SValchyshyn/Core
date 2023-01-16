//
//  AmountView+Configuration.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 18.10.2021.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import UIKit
import Core

public extension AmountView {
	
	struct Configuration {
		
		// MARK: - Init.
		
		/// - Parameters:
		///   - isSymbolHidden: `true` if the currency symbol should not be shown, no matter the `customSymbol` parameter value.
		///   - customSymbol: Currency Symbol value. If `nil`, the value from `DefaultPriceConfiguration` will be used instead.
		///   - symbolMargin: The distance, in points, between the decimals/ amount and the currency symbol. Only applied for `AmountView.Mode.horizontal`.
		///   - customSymbolGravity: Symbol vertical position. Could be top, bottom or center. If `nil`, the value from `DefaultPriceConfiguration` will be used instead.
		///   - customSymbolPosition: Configures whether symbol should be at the beginning or at the end of string. If `nil`, the value from `DefaultPriceConfiguration` will be used instead.
		///   - customSymbolCapitalization: Configures whether symbol should be at the beginning or at the end of string If `nil`, the value from `DefaultPriceConfiguration` will be used instead.
		///   - symbolFontSize: Custom font size for the decimals. If `nil` the configuration font size will be used.
		///   - decimalMargin: The distance, in points, between the `amount` and `decimals`.
		///   - decimalFontSize: Custom font size for the decimals. If `nil` the configuration font size will be used.
		///   - customDecimalType: Decimal part size type. Could be.normal size or small (superscript/subscript). If `nil`, the value from `DefaultPriceConfiguration` will be used instead.
		///   - decimalAlignment: Should the decimals and currency values be arranged vertically or horizontally
		///   - customDecimalSeparator: Determines the symbol that is used to separate the decimals. If `nil`, the value from `DefaultPriceConfiguration` will be used instead.
		///   - customFontType: Set font type for label. Could be `large`, `huge` or `custom font`. If `nil`, the value from `DefaultPriceConfiguration` will be used instead.
		///   - customFontSize: Determines the size of the `currency` and `decimals`. Computed using the `Constants.subscriptFontRatio`. If `nil`, the value from `DefaultPriceConfiguration` will be used instead.
		public init( isSymbolHidden: Bool = false,
					 customSymbol: String? = nil,
					 symbolMargin: CGFloat = .zero,
					 customSymbolGravity: Gravity? = nil,
					 customSymbolPosition: Position? = nil,
					 customSymbolCapitalization: CapitalizationType? = nil,
					 symbolFontSize: CGFloat? = nil,
					 decimalMargin: CGFloat = .zero,
					 decimalFontSize: CGFloat? = nil,
					 customDecimalType: DecimalType? = nil,
					 decimalAlignment: Mode = .horizontal,
					 customDecimalSeparator: Separator? = nil,
					 customFontType: FontType? = nil,
					 customFontSize: CGFloat? = nil ) {
			// A new instance will be provided every time it's injected, not a `Singlaton` one.
			var defaultConfiguration: DefaultPriceConfiguration = ServiceLocator.inject()
			if isSymbolHidden {
				defaultConfiguration.symbol = ""
			} else {
				customSymbol.map { defaultConfiguration.symbol = $0 }
			}
			self.symbolMargin = symbolMargin
			customSymbolGravity.map { defaultConfiguration.symbolLayout.gravity = $0 }
			customSymbolPosition.map { defaultConfiguration.symbolLayout.position = $0 }
			customSymbolCapitalization.map { defaultConfiguration.symbolLayout.capitalization = $0 }
			self.symbolFontSize = symbolFontSize
			self.decimalMargin = decimalMargin
			self.decimalFontSize = decimalFontSize
			customDecimalType.map { defaultConfiguration.decimalType = $0 }
			self.decimalAlignment = decimalAlignment
			customDecimalSeparator.map { defaultConfiguration.decimalSeparator = $0 }
			customFontType.map { defaultConfiguration.fontType = $0 }
			customFontSize.map { defaultConfiguration.fontSize = $0 }
			self.priceConfiguration = defaultConfiguration
		}
		
		/// Contains language specific information about how to display the `currency`. A default value will be provided by the `inject()` but will be used as an "accumulator" of the different
		/// customizations and configurations that every particular `AmountView` has.
		public let priceConfiguration: DefaultPriceConfiguration
		
		// MARK: - Public interface.
		// MARK: - Currency Symbol
		
		/// Currency Symbol value
		public var symbol: String { priceConfiguration.symbol }
		
		/// The distance, in points, between the decimals/ amount and the currency symbol. Only applied for `AmountView.Mode.horizontal`.
		public let symbolMargin: CGFloat
		
		/// Symbol vertical position. Could be top, bottom or center.
		public var symbolGravity: Gravity { priceConfiguration.symbolLayout.gravity }
		
		/// Configures whether symbol should be at the beginning or at the end of string
		public var symbolPosition: Position { priceConfiguration.symbolLayout.position }
			
		/// Configures whether symbol should be at the beginning or at the end of string
		public var symbolCapitalization: CapitalizationType { priceConfiguration.symbolLayout.capitalization }
			
		/// Custom font size for the decimals. If `nil` the configuration font size will be used.
		public let symbolFontSize: CGFloat?
		
		// MARK: - Decimal.
		
		/// The distance, in points, between the `amount` and `decimals`.
		public let decimalMargin: CGFloat
		
		/// Custom font size for the decimals. If `nil` the configuration font size will be used.
		public let decimalFontSize: CGFloat?
		
		/// Decimal part size type. Could be.normal size or small (superscript/subscript).
		public var decimalType: DecimalType { priceConfiguration.decimalType }
			
		/// Should the decimals and currency values be arranged vertically or horizontally
		public let decimalAlignment: Mode
		
		/// Determines the symbol that is used to separate the decimals.
		public var decimalSeparator: Separator { priceConfiguration.decimalSeparator }
			
		// MARK: - Amount and Commonly shared.
		
		/// Set font type for label. Could be `large`, `huge` or `custom font`.
		public var fontType: FontType { priceConfiguration.fontType }
		
		/// Determines the size of the `currency` and `decimals`. Computed using the `Constants.subscriptFontRatio`.
		public var fontSize: CGFloat { priceConfiguration.fontSize }
		
		// MARK: - Public interface.
		
		/// Provides a new instance with the non-nil, specified values.
		public func with( customSymbol: String? = nil,
				   customSymbolMargin: CGFloat? = nil,
				   customSymbolGravity: Gravity? = nil,
				   customSymbolPosition: Position? = nil,
				   customSymbolCapitalization: CapitalizationType? = nil,
				   customSymbolFontSize: CGFloat? = nil,
				   customDecimalMargin: CGFloat? = nil,
				   customDecimalFontSize: CGFloat? = nil,
				   customDecimalType: DecimalType? = nil,
				   customDecimalAlignment: Mode? = nil,
				   customDecimalSeparator: Separator? = nil,
				   customFontType: FontType? = nil,
				   customFontSize: CGFloat? = nil ) -> Configuration {
			Configuration( customSymbol: customSymbol ?? symbol,
						  symbolMargin: customSymbolMargin ?? symbolMargin,
						  customSymbolGravity: customSymbolGravity ?? symbolGravity,
						  customSymbolPosition: customSymbolPosition ?? symbolPosition,
						  customSymbolCapitalization: customSymbolCapitalization ?? symbolCapitalization,
						  symbolFontSize: customSymbolFontSize ?? symbolFontSize,
						  decimalMargin: customDecimalMargin ?? decimalMargin,
						  decimalFontSize: customDecimalFontSize ?? decimalFontSize,
						  customDecimalType: customDecimalType ?? decimalType,
						  decimalAlignment: customDecimalAlignment ?? decimalAlignment,
						  customDecimalSeparator: customDecimalSeparator ?? decimalSeparator,
						  customFontType: customFontType ?? fontType,
						  customFontSize: customFontSize ?? fontSize )
		}
		
		/// - Returns: `nil` if the amount is an invalid value.
		func getIntegerAndDecimalPart( from amount: Double ) -> (String, String)? {
			let builder = AttributedPriceBuilder( config: priceConfiguration )
			guard let amountString = builder.getAmountString( from: amount ) else { return nil }
			return builder.getIntegerAndDecimalPart( from: amountString )
		}
		
		/// - Returns: The font specific for the `amount` label of the `AmountView`.
		func amountFont() -> UIFont {
			fontType.font
		}
		
		/// Determines the `font` of the decimal label based on the decimal `position`, `type` and other customizations.
		func decimalsFont() -> UIFont {
			// Is the decimal small or normal?
			// Regular: Use the regular font
			if decimalType == .normal { return fontType.font }
			
			// If we do not have a custom font, use the default one.
			let font = priceConfiguration.decimalFont ?? fontType.font
			// Compute the font size based on where the symbol is positioned and use the local decimalFontSize if we have one specified.
			let localDecimalFontSize = decimalFontSize ?? fontSize( for: priceConfiguration.decimalGravity )
			return font.withSize( localDecimalFontSize )
		}
		
		/// Determines the `font` of the currency label based on the symbol `gravity` and other font overwrites from the customization.
		func currencyFont() -> UIFont {
			// Use the regular fount for symbols with center gravity, used when we want all the labels to have the same font
			if symbolGravity == .center { return fontType.font }
			
			// If we do not have a custom font, use the default one.
			let font = priceConfiguration.symbolFont ?? fontType.font
			// Compute the font size based on where the symbol is positioned and use the local symbolFontSize if we have one specified.
			let localSymbolFontSize = symbolFontSize ?? fontSize( for: symbolGravity )
			return font.withSize( localSymbolFontSize )
		}
		
		/// Computes the size of the font of a component.
		/// - Parameter gravity: Agnostic representation of the position that the component might have in the container.
		private func fontSize( for gravity: Gravity ) -> CGFloat {
			let refSize = priceConfiguration.fontSize
			switch gravity {
			case .top, .bottom:
				return refSize * Constants.subscriptFontRatio
				
			case .center:
				return refSize
			}
		}
	}
}
