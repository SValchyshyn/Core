//
//  Chain.swift
//  Stores
//
//  Created by Coruț Fabrizio on 26.05.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation
import UIKit
import CoreUserInterface

/// Concrete implementation of the the brand which the store is associated with.
/// A `Chain` can can have multiple `Stores`, but a `Store` can be associated only with a single `Chain`.
public struct Chain: Codable, Hashable, Identifiable {
	
	/// The value to default to when a `Chain` cannot be mapped to a concrete case.
	public static let unknown: Chain = .init( id: "unknown", name: "", rank: NSNotFound, logoURLString: nil, logoWhiteURLString: nil, pinIconURLString: nil, largeLogoURLString: nil, aliasLogoURLString: nil, filterURLString: nil )
	
	/// Uniquely identifies the `Chain`.
	public let id: String

	/// Human readable identifier of the `Chain`.
	public let name: String

	/// Used in sorting the `Chains`. Does not reflect any characteristic about the `Store`, it's simply determined by marketing to promote a certain `chain` more than others.
	public let rank: Int

	/// Contains `URLs` to all the `chain specific assets`.
	public let urls: ChainURLContainer

	/// `UIColor` that is specific to the `chain`. Probably the dominant color.
	public let colorHexString: String?
	
	public var color: UIColor? {
		colorHexString.map { UIColor( $0 ) }
	}

	// MARK: - Init.

	/// - Parameters:
	///   - id: Uniquely identifies the `Chain`.
	///   - name: Human readable identifier of the `Chain`.
	///   - colorHexString: Hexadecimal representation of the `UIColor` that is specific to the `Chain`. Probably the dominant color.
	///   - rank: Used in sorting the `Chains`. Does not reflect any characteristic about the `Store`, it's simply determined by marketing to promote a certain `Chain` more than others. Default value: `Constants.defaultRank`.
	///   - logoURLString: `String` representation of the `URL` where the image that identifies the `Chain` can be found.
	///   - logoWhiteURLString: `String` representation of the `URL` where the `white variant of the image` that identifiess the `Chain` can be found.
	///   - pinIconURLString: `String` representation of the `URL` where the `image` that is used to represent the `Store as a pin on a map` can be found.
	///   - largeLogoURLString: `String` representation of the `URL` where the `higher resolution image` that is used to represent the `Store as a pin on a map` can be found.
	public init(
		id: String,
		name: String,
		colorHexString: String? = nil,
		rank: Int,
		logoURLString: String?,
		logoWhiteURLString: String?,
		pinIconURLString: String?,
		largeLogoURLString: String?,
		aliasLogoURLString: String?,
		filterURLString: String?
	) {
		self.id = id
		self.name = name
		self.colorHexString = colorHexString
		self.rank = rank
		self.urls = ChainURLContainer( logoURLString: logoURLString, whiteLogoURLString: logoWhiteURLString, pinIconURLString: pinIconURLString, largeLogoURLString: largeLogoURLString, aliasLogoURLString: aliasLogoURLString, filterURLString: filterURLString )
	}
}

extension Chain: Comparable {
	
	/// Comparison of brands used for sorting.
	public static func < ( lhs: Chain, rhs: Chain ) -> Bool {
		return lhs.rank < rhs.rank
	}
}

/// Customizes and aligns the models used to represent a `store chain` across legacy modules.
public protocol ChainProvider {

	/// Provides a `Chain` based on its unique identifier which can be mapped to an `app specific` representation.
	/// - Parameter chainId: Uniquely identifies a `Chain` among the ones used in the module.
	func chain( for chainId: String ) -> Chain
	
	/// Provides a `Chain` based on its unique identifier which can be mapped to an `app specific` representation.
	/// - Parameter chainId: Uniquely identifies a `Chain` among the ones used in the module.
	/// - Parameter storeName: Store name as addtional parameter to identify correct `Chain`.
	func chain( for chainId: String, storeName: String ) -> Chain
}

public extension ChainProvider {
	func chain( for chainId: String, storeName: String ) -> Chain {
		chain(for: chainId)
	}
}

/// Manages all the `URLs` of the assets needed by a `chain`.
public struct ChainURLContainer: Codable, Equatable, Hashable {

	/// Where the image that identifies the `chain` can be found.
	public let logo: URL?

	/// Where the `white variant of the image` that identifiess the `chain` can be found.
	public let whiteLogo: URL?

	/// Where the `image` that is used to represent the `Store as a pin on a map` can be found.
	public let pinIcon: URL?

	/// Where the image that identifies the `chain` can be found. As opposed to `logo`, this image has higher resolution.
	public let largeLogo: URL?
	
	/// Where the alias logo that identifiess the `chain` can be found.
	public let aliasLogo: URL?

	/// Where the image that is used in the `chain filtering` flow can be found.
	public let filter: URL?
	
	// MARK: - Init.

	/// - Parameters:
	///   - logoURLString: Where the image that identifies the `Chain` can be found.
	///   - whiteLogoURLString: Where the `white variant of the image` that identifiess the `Chain` can be found.
	///   - pinIconURLString: Where the `image` that is used to represent the `Store as a pin on a map` can be found.
	///   - largeLogoURLString: Where the image that identifies the `chain` can be found. As opposed to `logo`, this image has higher resolution.
	public init( logoURLString: String?, whiteLogoURLString: String?, pinIconURLString: String?, largeLogoURLString: String?, aliasLogoURLString: String?, filterURLString: String? ) {
		self.logo = URL( string: logoURLString ?? "" )
		self.whiteLogo = URL( string: whiteLogoURLString ?? "" )
		self.pinIcon = URL( string: pinIconURLString ?? "" )
		self.largeLogo = URL( string: largeLogoURLString ?? "" )
		self.aliasLogo =  URL( string: aliasLogoURLString ?? "" )
		self.filter = URL( string: filterURLString ?? "" )
	}
}
