//
//  IntegerSemanticVersion.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 29.10.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

/// `Semantic Versioning` implementation that does not take into account `release candidates` or `alpha/beta` versions and is only restricted to
/// `major`, `minor` and `patch` int values. Anything else will be considered a `non valid` value.
public struct IntegerSemanticVersion: Codable, Comparable, Equatable {
	
	public let major: UInt
	public let minor: UInt
	public let patch: UInt?
	
	// MARK: - Init.
	
	/// A default value whose `major` and `minor` values are equal to `0`.
	static let zero: IntegerSemanticVersion = .init( major: 0, minor: 0, patch: nil )
	
	/// - Parameter versionString: Contains the full version string. The default `separator == "."`.
	public init?( versionString: String ) {
		var components = versionString.components( separatedBy: "." )
		
		// Make sure we have at least the major and the minor.
		guard components.count >= 2,
			  // Make sure that they are ints.
			  let major = Int( components.removeFirst() ),
			  let minor = Int( components.removeFirst() ),
			  // Make sure that the values are not negative
			  !major.isNegative, !minor.isNegative else { return nil }
		
		// The patch is not the important, treat it as an optional.
		var patch: UInt?
		if let patchComponent = components.first {
			// If we have a patchComponent, make sure that it's a valid number, otherwise we need to fail.
			if let castedPatch = Int( patchComponent ), !castedPatch.isNegative {
				patch = UInt( castedPatch )
			} else { return nil }
		}
		self.init( major: UInt( major ), minor: UInt( minor ), patch: patch )
	}
	
	public init( major: UInt, minor: UInt, patch: UInt? ) {
		self.major = major
		self.minor = minor
		self.patch = patch
	}
	
	// MARK: - Comparable implementation.
	
	public static func < ( lhs: IntegerSemanticVersion, rhs: IntegerSemanticVersion ) -> Bool {
		// First compare the majors.
		guard lhs.major == rhs.major else { return lhs.major < rhs.major }
		
		// Then compare the minors
		guard lhs.minor == rhs.minor else { return lhs.minor < rhs.minor }
		
		// If the patch is `nil` then we can't really decide on comaprison.
		return lhs.patch ?? .zero < rhs.patch ?? .zero
	}
}

fileprivate extension Int {
	
	/// `true` if the value is less than exclusivly than 0.
	var isNegative: Bool { self < 0 }
}
