//
//  CGPoint-Extensions.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 10/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

public extension CGPoint {
	/**
	Computes the distance between two points.

	- parameter point:		The point to which we're trying to compute the distance.
	*/
	func distance( to point: CGPoint ) -> CGFloat {
		let dx = x - point.x	// swiftlint:disable:this identifier_name
		let dy = y - point.y	// swiftlint:disable:this identifier_name
		return sqrt( dx*dx + dy*dy )
	}
}
