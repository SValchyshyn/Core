//
//  InAppActionScheduler.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 15.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import UIKit

/// The manager is responsible for scheduling in app actions depening on app ready state
open class InAppActionScheduler {
	
	public typealias Completion = (Error?) -> Void
	
	/// `InAppActionable` to find executor for `InAppAction`
	private let inAppActionable: InAppActionable2
	
	public init(inAppActionable: InAppActionable2) {
		self.inAppActionable = inAppActionable
	}
	
	// MARK: - Scheduler
	
	/// Pending in-app action to be executed once the app is fully loaded
	private var pendingAction: (inAppAction: InAppAction2, completion: Completion?)?
	
	/// Flag indicating if we are done with the launch of the app
	private var appIsDoneLaunching = false
	
	/// Notify manager that the app is fully loaded
	open func appDidLaunch() {
		appIsDoneLaunching = true
		
		if let (inAppAction, completion) = pendingAction {
			pendingAction = nil
			inAppActionable.execute(inAppAction: inAppAction, completion: completion)
		}
	}
	
	/// Execute the given in-app action if the app is done launching or postpone it until the app is finished launching to make sure that all dependencies are initialized.
	open func schedule(_ inAppAction: InAppAction2, completion: Completion? = nil) {
		!appIsDoneLaunching
			? pendingAction = (inAppAction, completion)
			: inAppActionable.execute(inAppAction: inAppAction, completion: completion)
	}
	
}
