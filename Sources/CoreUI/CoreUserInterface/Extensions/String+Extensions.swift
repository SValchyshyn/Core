//
//  String+Extensions.swift
//  CoreUserInterface
//
//  Created by Ievgen Goloboiar on 28.08.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit
import Log

/// String attributes.
public enum StringAttribute {
	/// String color.
	case color( UIColor )
	
	/// String font.
	case font( UIFont )
	
	/// String mininal line height.
	case minimumLineHeight( CGFloat )
	
	/// String textAlignment.
	case alignment( NSTextAlignment )
	
	/// String characterSpacing.
	case characterSpacing( CGFloat )
	
	/// Linebreaking mode.
	case lineBreakMode( NSLineBreakMode )
	
	/// Underlined string.
	case isUnderlined
	
	/// Text with a horizontal line through their center
	case strikethrough
}

extension String {
	/// Apply attributes for string.
	/// - Parameter attributes: `StringAttribute`.
	/// - Returns: `NSMutableAttributedString` string object.
	public func attributed( _ attributes: StringAttribute... ) -> NSAttributedString {
		let attributedString = NSMutableAttributedString.init( string: self )
		let pargraphStyle = NSMutableParagraphStyle()
		let range = NSRange( location: 0, length: attributedString.length )
		
		for attribute in attributes {
			switch attribute {
			case .color( let color ):
				attributedString.addAttribute( NSAttributedString.Key.foregroundColor, value: color, range: range )
				
			case .font( let font ):
				attributedString.addAttribute( NSAttributedString.Key.font, value: font, range: range )
				
			case .characterSpacing( let characterSpacing ):
				attributedString.addAttribute( NSAttributedString.Key.kern, value: characterSpacing, range: range )
				
			case .minimumLineHeight( let minimumLineHeight ):
				pargraphStyle.minimumLineHeight = minimumLineHeight
				
			case .alignment( let alignment ):
				pargraphStyle.alignment = alignment
				
			case .lineBreakMode( let lineBreakMode ):
				pargraphStyle.lineBreakMode = lineBreakMode
				
			case .isUnderlined:
				attributedString.addAttributes( [.underlineStyle: NSUnderlineStyle.single.rawValue], range: range )
				
			case .strikethrough:
				attributedString.addAttribute( .strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range )
			}
		}
		
		attributedString.addAttribute( NSAttributedString.Key.paragraphStyle, value: pargraphStyle, range: range )
		
		return NSAttributedString( attributedString: attributedString )
	}

	/// Converts the string that contains HTML into NSAttributedString and applies particular font and color.
	/// - Parameters:
	///   - font: A font that will be applied.
	///   - color: A color that will be applied.
	/// - Returns: The `NSAttributedString` if conversion succeeded or `nil` in case of failure.
	public func convertHTMLToAttributedString(font: UIFont, color: UIColor) -> NSAttributedString? {
		// Wrap HTML in a span style
		let htmlWithStyle = "<span style=\"color: \(color.hexString(false)); font-family: \(font.fontName); font-size: \(font.pointSize)\">\(self)</span>"

		do {
			// Convert the string to NSData
			if let data = htmlWithStyle.data( using: String.Encoding.unicode, allowLossyConversion: true ) {
				// Convert HTML to attributed string
				let attributedString = try NSMutableAttributedString( data: data, options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html ], documentAttributes: nil )

				// Return only the string from the attributed string
				return attributedString
			}
		} catch {
			// Log the error and return `nil`
			Log.technical.log(.error, "Failed HTML conversions: \(error)", [.identifier("CoreUserInterface.String.convertHTMLToAttributedString")])
		}

		return nil
	}
}
