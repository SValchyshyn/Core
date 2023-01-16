//
//  FormattedLabel.swift
//  CoopM16
//
//  Created by Niels Nørskov on 09/06/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import Log

open class FormattedLabel: UILabel {
	@IBInspectable var lineHeight: CGFloat = 0

	override public var text: String? {
		get {
			return super.text
		}
		
		set {
			internalSetText( newValue )
		}
	}

	private func internalSetText( _ text: String? ) {
		guard let text = text, let font = font else {
			return
		}

		// Get bold font
		let boldDescriptor = font.fontDescriptor.withSymbolicTraits( .traitBold )
		let boldFont = UIFont( descriptor: boldDescriptor!, size: font.pointSize )

		// Create attributed string from text
		let attributedText = styleTagsWithFont(tags: ["b", "strong"], text: text, boldFont: boldFont )

		// Set attributed text
		self.attributedText = attributedText

		// Finally, set line height if specified
		if lineHeight > 0 {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = lineHeight
			let mutableAttrText = NSMutableAttributedString( attributedString: self.attributedText! )

			mutableAttrText.addAttributes( [.paragraphStyle: paragraphStyle], range: NSRange( location: 0, length: mutableAttrText.length ))
			super.attributedText = mutableAttrText
			self.setNeedsDisplay()
		}
	}

	private func styleTagsWithFont( tags: [String], text: String, boldFont: UIFont ) -> NSAttributedString? {
		let tmpText = NSMutableString()

		// Tags to replace
		let tagsString = tags.joined( separator: "|" )

		var ranges: [NSRange] = []
		do {
			// Regex to find links
			let regex = try NSRegularExpression( pattern: "<\\s*(?:\(tagsString))\\s*[^>]*?>(.*?)</\\s*(?:\(tagsString))\\s*>", options: [.caseInsensitive, .dotMatchesLineSeparators] )

			// Match
			var lastLocation = 0
			var tagOffset = 0

			let matches = regex.matches( in: text, options: [], range: NSRange( location: 0, length: (text as NSString).length ))

			for match: NSTextCheckingResult in matches {
				// Make sure we have two captured groups
				assert( match.numberOfRanges == 2, "Wrong number of capture groups. Expected 2, got \(match.numberOfRanges)" )

				// Append from last location up to beginning of first capture group
				tmpText.append( (text as NSString).substring( with: NSRange( location: lastLocation, length: match.range( at: 0 ).location-lastLocation )))

				let outerRange = NSRange( location: match.range( at: 0 ).location, length: match.range( at: 0 ).length ) // Range of bold text including tags
				let innerRange = NSRange( location: match.range( at: 1 ).location, length: match.range( at: 1 ).length ) // Range of bold text excluding tags

				// Get bold text
				let boldText = (text as NSString).substring( with: innerRange )

				// Start tag offset
				tagOffset += (innerRange.location - outerRange.location)

				// Remember bold text range adjusted for tag offset
				if innerRange.location - tagOffset >= 0 { // Bounds check
					ranges.append( NSRange( location: innerRange.location - tagOffset, length: innerRange.length ) )
				}

				// End tag offset
				tagOffset += (innerRange.location - outerRange.location + 1)

				// Append link text
				tmpText.append( boldText )

				// Update last location
				lastLocation = outerRange.location + outerRange.length
			}	// end for match in matches

			// Append remaining text
			tmpText.append( (text as NSString).substring( from: lastLocation ))

			// Set attributes on found ranges
			let attributedString = NSMutableAttributedString( string: tmpText as String )
			for range in ranges {
				attributedString.addAttributes( [.font: boldFont], range: range )
			}
			return attributedString
		} catch {
			Log.technical.log(.error, "Error setting bold text in FormattedLabel: \(error)", [.identifier("CoreUserInterface.FormattedLabel.styleTagsWithFont")])
			return nil
		}
	}

}
