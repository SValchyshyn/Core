//
//  Store+ContactInfo.swift
//  Stores
//
//  Created by Coruț Fabrizio on 18.05.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation

public extension Store {

	/// Contains information how the `Store` can be reached.
	struct ContactInfo {

		// MARK: - Properties.

		public let phoneNumber: String?
		public let email: String?

		// MARK: - Init

		public init( phoneNumber: String? = nil, email: String? = nil ) {
			self.phoneNumber = phoneNumber
			self.email = email
		}
	}
}
