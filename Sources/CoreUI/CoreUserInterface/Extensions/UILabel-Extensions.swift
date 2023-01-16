//
//  UILabel-Extensions.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 03/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

public extension UILabel {
	/**
	Updates the size of the `font`.

	- parameter size:		The new size that should be applied to the `.font`.
	*/
	func changeFontSize( to size: CGFloat ) {
		font = font.withSize( size )
	}
}

public extension UILabel {
	/// Return current number of lines in a given label.
	func currentNumberOfLines() -> Int {
		guard let labelText = text, let labelFont = font else {
			return 0
		}
		let maxSize: CGSize = .init(width: frame.size.width, height: .infinity)
		let lineHeight = font.lineHeight
		let text: NSString = .init(string: labelText)
		
		let textSize = text.boundingRect(with: maxSize,
										 options: .usesLineFragmentOrigin,
										 attributes: [NSAttributedString.Key.font: labelFont],
										 context: nil)
		let linesRoundedUp: Int = Int(ceil(textSize.height / lineHeight))
		return linesRoundedUp
	}
}
