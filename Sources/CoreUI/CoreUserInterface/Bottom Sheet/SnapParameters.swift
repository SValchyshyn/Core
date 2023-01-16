//
//  SnapParameters.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 18.11.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

public struct SnapParameters {

	/// The value to which we currently have to snap the container to.
	public let snapConstant: CGFloat

	/// The velocity of the detected fling. Used to determine the `initialSpringVelocity` of the animation for
	/// a smoother animation.
	public let flingVelocity: CGPoint

	public init( snapConstant: CGFloat, flingVelocity: CGPoint ) {
		self.snapConstant = snapConstant
		self.flingVelocity = flingVelocity
	}

	/// Returns a new instance by updating  just the `snapConstant` keeping the `flingVelocity` unchanged.
	/// - Parameter snapConstant: The new `snapConstant` value.
	func updating( snapConstant: CGFloat ) -> SnapParameters {
		.init( snapConstant: snapConstant, flingVelocity: flingVelocity )
	}
}
