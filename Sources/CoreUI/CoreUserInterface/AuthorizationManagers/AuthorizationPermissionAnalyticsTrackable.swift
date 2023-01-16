//
//  AuthorizationPermissionAnalyticsTrackable.swift
//  CoreUserInterface
//
//  Created by Valeriy Kolodiy on 12.04.2021.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import Foundation

public protocol AuthorizationPermissionAnalyticsTrackable {
	/// Used for tracking the pre-permission dialog view
	func trackPrepermissionDialogView(displayCount: Int)

	/// Used for tracking the pre-permission dialog `continue` button action
	func trackPrepermissionDialogContinueAction()

	/// Used for tracking the system permission dialog button actions
	func trackSystemDialogAction(isAccepted: Bool)
}
