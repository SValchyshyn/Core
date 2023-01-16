//
//  UILabel-Rects.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 23/01/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

extension UILabel {
	/**
	Returns all enclosing rects for the specified range.
	Since a range might span more than one line we can have more than one rect.
	Based on code from http://stackoverflow.com/q/26675439/1632704
	Note that we need to pass CGFloat.max for the textContainer's height. If we just used self.bounds.size, everything except the first line would not work.
	*/
	func enclosingRectsForCharacterRange(_ range: NSRange) -> [CGRect] {
		let attributedString: NSAttributedString
		if let attributedText = self.attributedText {
			// Use the unwrapped attrbitedText.
			attributedString = attributedText
		} else if let text = self.text {
			// Create the NSAttributedText using the curent label font.
			attributedString = NSAttributedString(string: text, attributes: [.font: font as Any])
		} else {
			// If we have either attributedText nor text, just return an empty array.
			return []
		}

		// Create text storage and layout manager
		let textStorage = NSTextStorage(attributedString: attributedString)
		let layoutManager = NSLayoutManager()
		textStorage.addLayoutManager(layoutManager)
		let textContainer = NSTextContainer(size: CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
		textContainer.lineFragmentPadding = 0
		textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping	// IMPORTANT: Be sure to _also_ set the label's wrapping to Word Warp. Even though it may look fine using Truncate Tail.
		layoutManager.addTextContainer(textContainer)
		let selectedRange = NSRange(location: NSNotFound, length: 0) // Never mind selection range - use entire text.

		// Enumerate all rects for this range
		var rects = [CGRect]()
		layoutManager.enumerateEnclosingRects(forGlyphRange: range, withinSelectedGlyphRange: selectedRange, in: textContainer) { rect, _ -> Void in
			rects.append(rect)
		}

		return rects
	}
}
