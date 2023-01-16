//
//  EdgeInsetLabel.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 30/01/2018.
//  Copyright © 2018 Greener Pastures. All rights reserved.
//

import UIKit

/**
Label which allows us to add padding around the text.
Inspired from [this answer](http://stackoverflow.com/questions/21167226/resizing-a-uilabel-to-accomodate-insets/21267507#21267507).
*/
@IBDesignable public class EdgeInsetLabel: UILabel {
	// MARK: - IBInspectables.

	@IBInspectable var leftTextInset: CGFloat = 0.0 {
		didSet {
			textInsets.left = leftTextInset
		}
	}

	@IBInspectable var rightTextInset: CGFloat = 0.0 {
		didSet {
			textInsets.right = rightTextInset
		}
	}

	@IBInspectable var topTextInset: CGFloat = 0.0 {
		didSet {
			textInsets.top = topTextInset
		}
	}

	@IBInspectable var bottomTextInset: CGFloat = 0.0 {
		didSet {
			textInsets.bottom = bottomTextInset
		}
	}

	var textInsets = UIEdgeInsets.zero {
		didSet { invalidateIntrinsicContentSize() }
	}
	
	override public func textRect( forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int ) -> CGRect {
		let insetRect = bounds.inset( by: textInsets )
		let textRect = super.textRect( forBounds: insetRect, limitedToNumberOfLines: numberOfLines )
		let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right )
		return textRect.inset( by: invertedInsets )
	}
	
	override public func drawText( in rect: CGRect ) {
		super.drawText( in: rect.inset( by: textInsets ) )
	}
}
