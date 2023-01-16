//
//  TrackingAuthorizationDialog.swift
//  CoopUI
//
//  Created by Georgi Damyanov on 20/01/2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import UIKit
import AppTrackingTransparency

/**
Container for enqueueing an ATTrackingManager authorization dialog via the `AlertCoordinator`
*/
@available(iOS 14, *)
public struct TrackingAuthorizationDialog: AlertRepresenting {
	let completion: (ATTrackingManager.AuthorizationStatus) -> Void

	/// Explicit public initializer, since the default one is internal
	public init(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
		self.completion = completion
	}

	public func present( overViewController: UIViewController, didDismiss: @escaping () -> Void ) {
		ATTrackingManager.requestTrackingAuthorization { status in
			self.completion( status )
			didDismiss()
		}
	}

	public func isEqualTo(_ otherAlert: AlertRepresenting) -> Bool {
		// We are comparing with another TrackingAuthorizationDialog, treat them as equal
		return otherAlert is TrackingAuthorizationDialog
	}
}
