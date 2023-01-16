//
//  LineHeightAdjustingLabel.swift
//  CoopM16
//
//  Created by Coruț Fabrizio on 29/11/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

/// Adjusts the height occupied by the text, hence the label, using the `.maximumLineHeight` and `minimumLineHeight`
/// of the `NSMutableParagarphStyle` to be the `font.pointSize - pointSizeReduction`.
/// This is often needed for fonts who have extra top or bottom padding.
public final class LineHeightAdjustingLabel: UILabel {
	// MARK: - Properties.

	/// How many points off of the `font.pointSize` should be subtracted in order to determine the line height.
	@IBInspectable public var pointSizeReduction: CGFloat = 1

	override public var text: String? {
		get {
			return super.text
		}
		
		set {
			guard let string = newValue else {
				// Fall-back for nil values.
				super.text = newValue
				return
			}

			// Control the line height by modifying the maximumLineHeight and minimumLineHeight.
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.maximumLineHeight = font.pointSize - pointSizeReduction
			paragraphStyle.minimumLineHeight = font.pointSize - pointSizeReduction
			paragraphStyle.lineBreakMode = lineBreakMode
			paragraphStyle.alignment = textAlignment

			super.attributedText = NSAttributedString( string: string, attributes: [.paragraphStyle: paragraphStyle] )
		}
	}

	override public var attributedText: NSAttributedString! {
		get {
			return super.attributedText
		}
		
		set {
			guard let attributed = newValue else {
				// Fall-back for nil values.
				super.attributedText = newValue
				return
			}

			if let paragraphStyle = attributed.attribute( .paragraphStyle, at: 0, effectiveRange: nil ) as? NSMutableParagraphStyle {
				// The attributedString actually contains a paragraphStyle.
				// Modify only the maximumLineHeight and the minimumLineHeight
				let usedFont = attributed.attribute( .font, at: 0, effectiveRange: nil ) as? UIFont ?? font! // There should be a font on the label. -FAIO

				paragraphStyle.maximumLineHeight = usedFont.pointSize - pointSizeReduction
				paragraphStyle.minimumLineHeight = usedFont.pointSize - pointSizeReduction

				let mutableAttributedString = NSMutableAttributedString( attributedString: attributed )
				mutableAttributedString.addAttribute( .paragraphStyle, value: paragraphStyle, range: NSRangeFromString( attributed.string ) )
				super.attributedText = mutableAttributedString
			} else {
				// There is no paragraphStyle. Create one.
				// Control the line height by modifying the maximumLineHeight and minimumLineHeight.
				let paragraphStyle = NSMutableParagraphStyle()
				paragraphStyle.maximumLineHeight = font.pointSize - pointSizeReduction
				paragraphStyle.minimumLineHeight = font.pointSize - pointSizeReduction
				paragraphStyle.lineBreakMode = lineBreakMode
				paragraphStyle.alignment = textAlignment

				let mutableAttributedString = NSMutableAttributedString( attributedString: attributed )
				mutableAttributedString.addAttribute( .paragraphStyle, value: paragraphStyle, range: NSRangeFromString( attributed.string ) )
				super.attributedText = mutableAttributedString
			}
		}
	}

	// MARK: - Custom init.

	required public init?( coder aDecoder: NSCoder ) {
		super.init( coder: aDecoder )
		customInit()
	}

	override public init( frame: CGRect ) {
		super.init(frame: frame)
		customInit()
	}

	override public func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		customInit()
	}

	override public func awakeFromNib() {
		super.awakeFromNib()
		customInit()
	}

	private func customInit() {	}
}
