//
//  ActivationInfo.swift
//  CoopModels
//
//  Created by Coruț Fabrizio on 14/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

public struct ActivationInfo: Codable {
	// MARK: - Codable.

	enum CodingKeys: String, CodingKey {
		case maxActivatedOffers = "activatedMax"
		case activatedOffersCount = "activatedCount"
		case coupons
	}

	// MARK: - Properties.

	/// The maximum number of offers that can be activated.
	public let maxActivatedOffers: Int

	/// The total number of currently activated offers.
	public let activatedOffersCount: Int

	/// Associated `Coupons`.
	public var coupons: [CoopCoupon]

	// MARK: - Init.

	// Provide the init since the compiler doesn't know to synthesize it.
	public init( maxActivatedOffers: Int, activatedOffersCount: Int, coupons: [CoopCoupon] ) {
		self.maxActivatedOffers = maxActivatedOffers
		self.activatedOffersCount = activatedOffersCount
		self.coupons = coupons
	}
}
