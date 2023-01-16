//
//  SheetPositioning.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 18.11.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

/// Embeds information about a bottom sheet's positioning in absolute and relative terms.
public struct SheetPositioning {

	/// Absolute value of the constraint that controls the bottom sheet.
	public let constant: CGFloat

	/// The minimum value that the constraint can have, when the sheet is visible on the screen, collapsed.
	public let collapsedConstant: CGFloat

	/// The maximum value that the constraint can have, when the sheet is visible on the screen, expanded
	public let expandedConstant: CGFloat

	/// The percentage, relative to the `collapsed` and `expanded` constants, that`constant` represents.
	public let percentage: CGFloat

	// MARK: - Init.

	public init( constant: CGFloat, collapsedConstant: CGFloat, expandedConstant: CGFloat ) {
		self.constant = constant
		self.collapsedConstant = collapsedConstant
		self.expandedConstant = expandedConstant

		let minConstant = min( collapsedConstant, expandedConstant )
		let maxConstant = max( collapsedConstant, expandedConstant )
		self.percentage =  (constant - minConstant) / (maxConstant - minConstant)
	}
}
