//
//  EllipsisLabel.swift
//  CoopM16
//
//  Created by Niels Nørskov on 25/07/2017.
//  Copyright © 2017 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

/**
Label that can truncate text with an ellipsis.
You can also set lineHeight and letterSpacing like the LineHeightLabel.
*/
@IBDesignable public class EllipsisLabel: UILabel {
	@IBInspectable var lineHeight: CGFloat = 0
	@IBInspectable var letterSpacing: CGFloat = 0

	override public func awakeFromNib() {
		super.awakeFromNib()

		let currentText = text
		self.text = currentText
	}

	override public func layoutSubviews() {
		super.layoutSubviews()

		// Make sure the text still fits after autolayout where the correct width is known
		let currentText = text
		self.text = currentText
	}

	override public var text: String? {
		get {
			return super.text
		}
		
		set {
			if let string = newValue {

				// If we have a custom line height or spacing, add it; otherwise call super directly
				if lineHeight > 0 || letterSpacing > 0 {
					// Create mutable attributed string
					let mutableAttrText = NSMutableAttributedString( string: truncatedText( text: string ))

					if lineHeight > 0 {
						let paragraphStyle = NSMutableParagraphStyle()
						paragraphStyle.lineSpacing = lineHeight
						paragraphStyle.lineBreakMode = self.lineBreakMode
						paragraphStyle.alignment = self.textAlignment

						mutableAttrText.addAttributes( [.paragraphStyle: paragraphStyle], range: NSRange( location: 0, length: mutableAttrText.length ))
					}

					if letterSpacing > 0 {
						mutableAttrText.addAttribute( .kern, value: letterSpacing, range: NSRange( location: 0, length: mutableAttrText.length ) )
					}

					super.attributedText = mutableAttrText
					return
				}
			}

			// Fall-through for both newValue == nil and lineHeight/lineSpacing == 0
			super.text = newValue
		}
	}

	override public func prepareForInterfaceBuilder() {
		let currentText = text
		self.text = currentText
	}

	// MARK: - Private helper functions

	/**
	Truncate text to correctly fit a multi line label including ellipsis.
	NB: Set label linebreak mode to word wrap and numberOfLines != 0 for this to work as expected.

	- parameter text:	Text to truncate with ellipsis to fit within label width.
	- returns:			Truncated text including ellipsis
	*/
	private func truncatedText( text: String ) -> String {
		// Get max required height
		let maxHeight = self.requiredHeight()
		let attributes = attributesForSizeCalculation()

		// Calculate initial height text
		let initialHeight = (text as NSString).boundingRect( with: CGSize( width: bounds.width, height: CGFloat.greatestFiniteMagnitude ), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height

		if initialHeight <= maxHeight {
			// The original text fits within the avaliable height, so return it without modification
			return text
		} else {
			// The original text is too high, split into components and add an ellipsis
			var components = text.components( separatedBy: " " )
			components.append( "..." )

			// Keep removing last component before ellipsis until the text fits within the available height
			var truncatedText = ""
			while true {
				// Bounds check
				if components.count < 2 {
					break
				}

				// Remove last component before ellipsis
				components.remove( at: components.count-2 )

				// Rejoin truncated text
				truncatedText = components.joined( separator: " " )

				// Calculate height of truncated text
				let truncatedHeight = (truncatedText as NSString).boundingRect( with: CGSize( width: bounds.width, height: CGFloat.greatestFiniteMagnitude ), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height

				if truncatedHeight <= maxHeight {
					// Text now fits within avaliable height, so break out of loop
					break
				}
			}

			// Return the truncated text incl. ellipsis
			return truncatedText
		}
	}

	/**
	Get text attributes for width calculation.

	- returns:	Text attributes
	*/
	private func attributesForSizeCalculation() -> [NSAttributedString.Key: Any] {
		var attributes: [NSAttributedString.Key: Any] = [:]

		attributes[ .font ] = self.font

		if lineHeight > 0 {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = lineHeight
			paragraphStyle.lineBreakMode = self.lineBreakMode
			paragraphStyle.alignment = self.textAlignment
			attributes[ .paragraphStyle ] = paragraphStyle
		}
		if letterSpacing > 0 {
			attributes[ .kern ] = letterSpacing
		}

		return attributes
	}

	/**
	Get required height for labels number of lines.
	If numberOfLines is set to zero, infinite height is returned.

	- returns:	Required height
	*/
	private func requiredHeight() -> CGFloat {
		if numberOfLines == 0 {
			return CGFloat.greatestFiniteMagnitude
		}

		var lines: [String] = []
		for lineNo in 0..<numberOfLines {
			lines.append( "LINE" + String( lineNo ) )
		}
		let lineText = lines.joined(separator: "\n" )

		let size = (lineText as NSString).boundingRect( with: CGSize( width: bounds.width, height: CGFloat.greatestFiniteMagnitude ), options: .usesLineFragmentOrigin, attributes: attributesForSizeCalculation(), context: nil).size

		return size.height
	}
}
