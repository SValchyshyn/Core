//
//  UnderlinedButton.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 31/08/2017.
//  Copyright © 2017 Greener Pastures. All rights reserved.
//

import UIKit

@IBDesignable public class UnderlinedButton: UIButton {
	private struct Constants {
		static let underlineWidth: CGFloat = 3
	}

	override public func draw(_ rect: CGRect ) {
		// Find the bottom left and right corners of the button
		let startingPoint = CGPoint( x: rect.minX, y: rect.maxY )
		let endingPoint = CGPoint( x: rect.maxX, y: rect.maxY )
		let path = UIBezierPath()

		// Draw a line between the two points
		path.move( to: startingPoint )
		path.addLine( to: endingPoint )
		path.lineWidth = Constants.underlineWidth
		titleColor( for: .selected )?.setStroke()

		path.stroke()
	}
}
