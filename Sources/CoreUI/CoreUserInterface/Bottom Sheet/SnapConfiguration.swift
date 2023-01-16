//
//  SnapConfiguration.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 18.11.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

public struct SheetSnapConfiguration {

	/// The constraint that determines the snap.
	let constraintConstant: CGFloat

	/// Absolute value that represents the distance (in points) that must be exceeded (in any direction) in order to snap to a new state.
	let threshold: CGFloat

	public init( constraintConstant: CGFloat, threshold: CGFloat ) {
		self.constraintConstant = constraintConstant
		self.threshold = threshold
	}
}
