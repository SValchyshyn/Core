//
//  PriceSuperscriptLabel.swift
//  CoopM16
//
//  Created by Niels Nørskov on 04/05/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import Log

@IBDesignable public class PriceSuperscriptLabel: UILabel {
	private struct Constants {
		/// The ratio of the super script font size in comparison with the main font size
		static let superScriptFontRatio: CGFloat = 0.5
		
		/// The baseline offset in comparinson with the main font size
		static let baselineOffsetRatio: CGFloat = 0.35
	}

	/// Manually set offset to match font type and size. You only need to set this if the calculated offset value is wrong e.g. for very small labels.
	@IBInspectable public var superOffset: CGFloat = 0

	/// Manually set super font size. You only need to set this if the calculated offset value is wrong e.g. for very small labels.
	@IBInspectable public var superSize: CGFloat = 0

	/// Set superscripted text with comma separated decimal part e.g. "99,95"
	@IBInspectable public var superscriptedText: String? {
		get {
			return text	// Warning: this will remove the comma from the current value
		}
		
		set {
			if let newValue = newValue {
				let components = newValue.components( separatedBy: "," )
				configureWithComponents( components )
			}
		}
	}
	
	/// Set superscripted text with a double value
	public var superscriptedValue: Double? {
		get {
			// Add the missing decimal separator in the text string and make the number formatter extract the number
			if var text = text, let decimalSeparator = String.priceStringFormatter.decimalSeparator?.first, let indexBeforeFirstDecimal = text.index( text.endIndex, offsetBy: -NumberFormatter.Constants.numberOfFractionDigits, limitedBy: text.startIndex ) { // The `limitedBy:` argument makes sure that we don't go before the first index
				text.insert(decimalSeparator, at: indexBeforeFirstDecimal)
				return String.priceStringFormatter.number( from: text )?.doubleValue
			}
			return nil
		}
		
		set {
			let formatter = String.priceStringFormatter
			if let newValue = newValue, let newText = formatter.string( from: NSNumber(value: newValue) ) {
				let components = newText.components( separatedBy: "," )
				configureWithComponents( components )
			} else {
				self.text = ""
			}
		}
	}
	
	override public func prepareForInterfaceBuilder() {
		if let text = text {
			let components = text.components( separatedBy: "," )
			configureWithComponents( components )
		}
	}

	// MARK: - Private methods

	/**
	Sets the text from the components specified.

	Only one or two components are allowed.
	*/
	private func configureWithComponents( _ components: [String] ) {
		if components.count == 1 {
			configureWith( normalText: components[0], superText: "" )
		} else if components.count == 2 {
			configureWith( normalText: components[0], superText: components[1] )
		} else {
			Log.technical.log(.error, "Unexpected number of components in PriceSuperscriptLabel", [.identifier("CoreUserInterface.PriceSuperscriptLabel.configureWithComponents")])
		}
	}

	private func configureWith( normalText: String, superText: String ) {
		var calculatedOffset = self.font.pointSize * Constants.baselineOffsetRatio
		if superOffset != 0 {
			// Use value manually set in interface builder
			calculatedOffset = superOffset
		}

		var calculatedSuperSize = self.font.pointSize * Constants.superScriptFontRatio
		if superSize != 0 {
			// Use value manually set in interface builder
			calculatedSuperSize = superSize
		}

		let attributedString = NSMutableAttributedString( string: normalText + superText )
		let superScriptFont = self.font.withSize( calculatedSuperSize )
		attributedString.setAttributes( [ .font: superScriptFont, .baselineOffset: calculatedOffset], range: NSRange(location: normalText.count, length: superText.count ))

		self.attributedText = attributedString
	}
}
