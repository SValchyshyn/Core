//
//  AppStoreReviewManager.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 03/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import StoreKit
import UserDefault
import Tracking

public class AppStoreReviewManager {
	private enum Keys {
		static let reviewDate = "reviewDate"
		static let reviewPromptedEventInfoKey = "app_review_prompted"
	}

	/// Used just as storage convenience. The logic for setting this variable should only reside in the `setter` of the `reviewDate` variable.
	@UserDefault( key: Keys.reviewDate, defaultValue: nil, migration: Migration( key: Keys.reviewDate ) )
	private static var _reviewDate: Date?

	/// Will be set only for a fraction of the cases. Might be nil after assignment.
	public static var reviewDate: Date? {
		get {
			return _reviewDate
		}
		set {
			guard let value = newValue else {
				// We shouldn't be able to remove this date by assigning it to nil.
				return
			}

			// If we already have a set date, overrwrite it only if the newValue == Date.distantFuture
			if _reviewDate != nil {
				if value == Date.distantFuture {
					_reviewDate = value
				}
			}
			// Only a small fraction of the winners should get prompted to review.
			else if Int.random( in: 0..<100 ) < 2 {
				_reviewDate = value
			}
		}
	}

	/// Also verifies if we have passed the review date and only then presents the review prompt.
	public class func requestReview() {
		if #available(iOS 10.3, *) {
			// If we have passed the reviewDate.
			guard let reviewDate = reviewDate, reviewDate < Date() else {
				return
			}

			// Track app review alert prompting
			Tracking.shared.trackEvent( event: Keys.reviewPromptedEventInfoKey, parameters: nil, includeExtraInfo: false )

			// Set the date to distantFuture, so we won't ask again for the review.
			self.reviewDate = Date.distantFuture
			SKStoreReviewController.requestReview()
		}
	}
}
