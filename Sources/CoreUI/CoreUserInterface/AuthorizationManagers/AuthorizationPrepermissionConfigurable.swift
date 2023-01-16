//
//  AuthorizationPrepermissionConfigurable.swift
//  CoreUserInterface
//
//  Created by Valeriy Kolodiy on 19.03.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

/// Protocol that defines the interface requirements for the authorization pre-permission logic configuration
public protocol AuthorizationPrepermissionConfigurable {

	/// Pre-permission dialog localizations
	/// - title: Text used for the pre-permission dialog title
	/// - body: Text used for the pre-permission dialog body
	/// - buttonTitle: Text used for the pre-permission dialog `Continue` button
	typealias PrePermissionDialog = (title: String, body: String, buttonTitle: String)
	
	/// Returns pre-permission dialog message. If the value is `nil`, the system dialog will be shown right away.
	var prePermissionDialog: PrePermissionDialog? { get }
	
}
