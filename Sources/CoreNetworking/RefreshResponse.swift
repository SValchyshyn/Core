//
//  RefreshResponse.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 27/10/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public struct RefreshResponse<T> {
	/// `true` if the data was still valid and was provided from `CoreData`.
	public let isCachedData: Bool

	/// The refreshed model.
	public let model: T

	public init( isCachedData: Bool, model: T ) {
		self.isCachedData = isCachedData
		self.model = model
	}
}
