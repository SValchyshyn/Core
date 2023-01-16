//
//  AuthUIRenewManager.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 01.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Core
import RemoteLog

/// Wrapper for `AuthUIPresentation` that manages one UI execution at the same time.
actor AuthUIRenewManager {
	
	enum RenewTokenResult {
		/// Success auth token result.
		case authToken(AuthToken)
		
		/// Other UI renew token flow was in progress, so needs to restart auth config flow with new cookies after it is over.
		case cookiesUpdated
	}
	
	/// Use shared instance because only one UI token renew flow can be at the same time.
	static let shared = AuthUIRenewManager()
	
	/// Condition variable to avoid multiple UI running flows.
	private var inProgressCondition: AsyncCondition?
	
	@Injectable private var presentation: AuthUIPresentation
	
	private init() {}
	
	/// Performs UI renew token flow. Only one UI renew token flow is allowed at the same time.
	func renewToken(wuth authConfig: AuthConfig) async throws -> RenewTokenResult {
		// Check if there is UI flow in progress.
		if let condition = inProgressCondition {
			// Wait for UI flow finish
			await condition.wait()
			
			// Return restart renew token flow
			return .cookiesUpdated
		}
		
		// Create async condition variable to avoid multiple UI running flows
		inProgressCondition = AsyncCondition()
		defer {
			inProgressCondition?.startBroadcastTask()
			inProgressCondition = nil
		}
		
		// Get auth token from UI flow
		let authToken = try await presentation.renewToken(authConfig: authConfig)
		return .authToken(authToken)
	}
	
}
