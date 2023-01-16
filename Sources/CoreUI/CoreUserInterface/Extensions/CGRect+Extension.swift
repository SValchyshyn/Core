//
//  CGRect+Extension.swift
//  CoreUserInterface
//
//  Created by Eugene on 25.09.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

public extension CGRect {
	
	/// Returns the center of the rect
	var center: CGPoint {
		CGPoint(x: midX,
				y: midY)
	}
	
	/// Return intersection percentage of two rects.
	/// - Parameter otherRect: `CGRect` object.
	/// - Returns: `CGFloat` percentage value.
	func intersectionPercentage( _ otherRect: CGRect ) -> CGFloat {
		// If no intersection - return 0.
		if !intersects(otherRect) { return 0 }
		let intersectionRect = intersection( otherRect )
		
		let maxPercentageValue: CGFloat = 100
		
		// If full match for intersection - return 100%.
		if intersectionRect == self || intersectionRect == otherRect { return maxPercentageValue }
		
		// Determine intersection areas.
		let intersectionArea = intersectionRect.width * intersectionRect.height
		let area = width * height
		let otherRectArea = otherRect.width * otherRect.height
		
		// Calculate intersection ratio.
		let sumArea = area + otherRectArea
		let sumAreaNormalized = sumArea / 2.0
		
		return intersectionArea / sumAreaNormalized * maxPercentageValue
	}
}
