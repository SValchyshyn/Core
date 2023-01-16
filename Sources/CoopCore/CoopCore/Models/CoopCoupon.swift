//
//  CoopCoupon.swift
//  CoopModels
//
//  Created by Coruț Fabrizio on 16/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

/**
Coupons are generated from the activation of `Personal` and `Campaign Offers`.
They provide information such as how many times the offer can be used, how many times it has been used already.
They represent a discount on an item.
*/
public struct CoopCoupon: Codable {
	// MARK: - Codable.

	enum CodingKeys: String, CodingKey {
		case activityID = "activityId"
		case status
		case maxUsages = "usagesMax"
		case remainingUsages = "usagesRemaining"
		case type = "couponType"
		case activationTimestamp = "activationTime"
	}

	/// Defines the type of `Offers` which the `Coupon` can represent.
	public enum CouponType: String, Codable, CaseIterable {
		case campaign = "AppKupOffer"
		case personal = "PersonalOffer"
	}

	/// Defines the possible activation states of an `Coupon`.
	public enum Status: String, Codable {
		case notActivated = "NotActivated"
		case pendingActivation = "PendingActivation"
		case activated = "Activated"
		case failed = "Failed"
	}

	// MARK: - Properties.

	/// Unique identifier of the `Coupon`.
	public let activityID: UInt64

	/// Activation state in which the `Coupon` is currently in.
	public let status: Status

	/// The maximum number of usages of the `Coupon`.
	public let maxUsages: Int

	/// The number of usages that we have left for this `Coupon`.
	public let remainingUsages: Int

	/// The type of `Offer` that the `Coupon` represents.
	public let type: CouponType

	/// Timestamp of when the `Coupon` has been activated.
	public let activationTimestamp: Date

	public init( from decoder: Decoder ) throws {
		let container = try decoder.container( keyedBy: CodingKeys.self )

		// Decode the max usages and remaining usages. We set them to zero if they are not present. Aligned with Android.
		self.maxUsages = try container.decodeIfPresent( Int.self, forKey: .maxUsages ) ?? 0
		self.remainingUsages = try container.decodeIfPresent( Int.self, forKey: .remainingUsages ) ?? 0

		// Decode the remaining properties
		activityID = try container.decode( UInt64.self, forKey: .activityID )
		status = try container.decode( Status.self, forKey: .status )
		type = try container.decode( CouponType.self, forKey: .type )
		activationTimestamp	 = try container.decode( Date.self, forKey: .activationTimestamp )
	}

	public init(activityID: UInt64, status: CoopCoupon.Status, maxUsages: Int, remainingUsages: Int, type: CoopCoupon.CouponType, activationTimestamp: Date) {
		self.activityID = activityID
		self.status = status
		self.maxUsages = maxUsages
		self.remainingUsages = remainingUsages
		self.type = type
		self.activationTimestamp = activationTimestamp
	}
}
