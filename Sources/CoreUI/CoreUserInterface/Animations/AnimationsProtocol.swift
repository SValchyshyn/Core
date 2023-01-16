//
//  AnimationsProtocol.swift
//  CoreUserInterface
//
//  Created by Nazariy Vlizlo on 02.12.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import Lottie

/// Protocol for injecting Lottie animations
public protocol AnimationsProtocol {
	/// Generic loading spinner animation
	var loadingAnimation: Animation? { get }
	
	/// Generic success checkmark animation
	var successAnimation: Animation? { get }
	
	/// Animations for bonus blob balance updates
	///  - Key: number of drops in animation
	///  - Value: current animation with number of drops
	///
	///  For example,  `bonusBlobAnimations[ 2: someAnimation ]` return animation with 2 drops or nil, if it's not present.
	var bonusBlobAnimations: [ Int: Animation? ] { get }
	
	/// Return animation associated with number of drops from `bonusBlobAnimations` dictionary
	/// - Parameter drops: number of drops in animation
	func bonusBlobAnimationWith( drops: Int ) -> Animation?
}
