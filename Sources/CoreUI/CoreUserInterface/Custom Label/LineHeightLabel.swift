//
//  LineHeightLabel.swift
//  Danes Abroad
//
//  Created by Jens Willy Johannsen on 13/02/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

import UIKit

@IBDesignable open class LineHeightLabel: UILabel {
	@IBInspectable var lineHeight: CGFloat = 0
	@IBInspectable var letterSpacing: CGFloat = 0
	
	/* MARK: - Fix for custom fonts bug.
	Overrided due to bug with custom fonts. Some elements (like apostrophs, diacritics or dots above letters) from custom fonts are cutted.
	It happens because space for ascender is calculated/set wrong. To avoid this we need just add additional space on the top of UILabel.
	The space was chosen by the manual selection method and it is minimal needed value
	*/
	override open var intrinsicContentSize: CGSize {
		let selfSize: CGSize = super.intrinsicContentSize
		let space: CGFloat = font.ascender / 5
		return CGSize(width: selfSize.width, height: selfSize.height + space)
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()

		let currentText = text
		self.text = currentText
	}

	override open var text: String? {
		get {
			return super.text
		}
		
		set {
			if let string = newValue {
				// If we have a custom line height or spacing, add it; otherwise call super directly
				if lineHeight > 0 || letterSpacing > 0 {
					// Create mutable attributed string
					let mutableAttrText = NSMutableAttributedString( string: string )

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

	override open var attributedText: NSAttributedString! {
		get {
			return super.attributedText
		}
		
		set {
			// If we have a custom line height, add it; otherwise call super directly
			if lineHeight > 0 || letterSpacing > 0 {
				// Create mutable attributed string copy
				let mutableAttrText = NSMutableAttributedString( attributedString: newValue )

				if lineHeight > 0 {
					let paragraphStyle = NSMutableParagraphStyle()
					paragraphStyle.lineSpacing = lineHeight
					paragraphStyle.alignment = self.textAlignment
					mutableAttrText.addAttributes( [.paragraphStyle: paragraphStyle], range: NSRange( location: 0, length: mutableAttrText.length ))
				}

				if letterSpacing > 0 {
					mutableAttrText.addAttribute( .kern, value: letterSpacing, range: NSRange( location: 0, length: mutableAttrText.length ) )
				}

				super.attributedText = mutableAttrText
			} else {
				super.attributedText = newValue
			}
		}
	}

	override open func prepareForInterfaceBuilder() {
		let currentText = text
		self.text = currentText
	}
}
