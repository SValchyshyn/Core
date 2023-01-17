//
//  AuthRouter.swift
//  Authentication
//
//  Created by Ihor Zabrotskyi on 21.12.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation
import Core
import CoreUserInterface
import CoopCore
import AuthenticationDomain
import UIKit

public protocol AuthCompletionHandler {
	func handleCompletionAction(with authToken: AuthToken) async
}

public struct AuthCoordinator {
	
	private var authCompletionHandler: AuthCompletionHandler?
	
	public init(authCompletionHandler: AuthCompletionHandler? = nil) {
		self.authCompletionHandler = authCompletionHandler
	}
	
}

extension AuthCoordinator: AuthUIPresentation {
	
	public func authenticate(with authRequest: URLRequest, actionHandler: AuthWebActionHandler) async throws -> AuthToken {
		try await withCheckedThrowingContinuation { continuation in
			// Present on `AlertCoordinator` queue to avoid presenting over other alerts
			AlertCoordinator.shared.performBlock {
				self.presentWebAuthFlow(with: authRequest, actionHandler: actionHandler, completion: continuation.resume)
			}
		}
	}
	
	private func presentWebAuthFlow(with authRequest: URLRequest, actionHandler: AuthWebActionHandler, completion: @escaping (Result<AuthToken, Error>) -> Void) {
		guard let topViewController = UIViewController.topViewController() else {
			return completion(.failure(AuthManagerError.cancelledByUser))
		}
			
		let viewController = WebAuthViewController.fromBundleXib()
		let scanActionHandler = LoyaltyCardScanWebActionHandler(presenter: viewController)
		let closeRoute = CloseWebAuthFlowRoute(viewController: viewController, completion: completion)
		viewController.viewModel = WebAuthViewModel(authRequest: authRequest,
													authActionHandler: actionHandler,
													scanActionHandler: scanActionHandler,
													authCompletionHandler: authCompletionHandler,
													closeRoute: closeRoute)
		topViewController.presentInFullScreen(viewController, animated: true)
	}
	
}
