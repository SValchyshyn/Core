//
//  Models.swift
//  Stores
//
//  Created by Stepan Valchyshyn on 04.08.2020.
//  Copyright © 2020 Loop By Coop. All rights reserved.
//

import Foundation
import UIKit

/// Identifies a physical `store` and all the useful properties.
public struct Store {

	// MARK: - Properties.

	/// Uniquely identifies the physical `store`.
	public let id: String

	/// Extra unique identification of the `store`. Legacy.
	public let kardexId: Int

	/// Human friendly identifier of the `store`.
	public let name: String

	/// `true` if the store has `SelfScanning` machines installed in it.
	public let isSelfScanningEnabled: Bool

	/// Human readable information about where the `Store` is located.
	public let location: Location?

	/// The brand which the store is associated with.
	/// A `Chain` can can have multiple `Stores`, but a `Store` can be associated only with a single `Chain`.
	public let chain: Chain

	/// Schedule of the `Store`.
	public let openingHours: [OpeningHours]

	/// Contains information about how to contact the `Store`.
	public let contact: ContactInfo?
	
	/// Availability status of the `Store`.
	public let status: StoreStatus
	
	/// Availability type of the `Store`.
	public let type: StoreType
	
	/// Is it an operational store that should be displayed to user. Should prevent closed or test stores from being shown
	public var isOperational: Bool {
		return type == .public && status == .active
	}
	
	// MARK: - Init.

	/// - Parameters:
	///   - id: Uniquely identifies the physical `store`.
	///   - kardexId: Extra unique identification of the `store`. Legacy.
	///   - name: Human friendly identifier of the `store`.
	///   - isSelfScanningEnabled: `true` if the store has `SelfScanning` machines installed in it.
	///   - location: Human readable information about where the `Store` is located.
	///   - chain: The brand which the store is associated with.
	///   - openingHours: Schedule of the `Store`.
	///   - contact: Contains information about how to contact the `Store`.
	public init(
		id: String,
		kardexId: Int,
		name: String,
		isSelfScanningEnabled: Bool,
		location: Store.Location?,
		chain: Chain,
		openingHours: [Store.OpeningHours],
		contact: Store.ContactInfo?,
		status: StoreStatus?,
		type: StoreType?
	) {
		self.id = id
		self.kardexId = kardexId
		self.name = name
		self.isSelfScanningEnabled = isSelfScanningEnabled
		self.location = location
		self.chain = chain
		self.openingHours = openingHours
		self.contact = contact
		// Default values for status and type
		self.status = status ?? .active
		self.type = type ?? .public
	}
}

public enum StoreStatus: String, Decodable {
	case active = "Active"
	case closed = "Closed"
}

public enum StoreType: String, Decodable {
	case `public` = "Public"
	case `internal` = "Internal"
}
