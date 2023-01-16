//
//  ActivationManaging.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 26/05/2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

public protocol ActivationManaging {
	/// Used for monitoring when an offer has been activated
	var offerActivatedNotificationName: Notification.Name { get }
}
