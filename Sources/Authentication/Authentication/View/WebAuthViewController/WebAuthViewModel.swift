//
//  WebAuthViewModel.swift
//  Authentication
//
//  Created by Olexandr Belozierov on 19.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import WebKit
import Combine
import Core
import AuthenticationDomain

class WebAuthViewModel {
	
	/// Auth url request to start web flow
	private let authRequest: URLRequest
	
	/// Handles authentication action and provides auth token
	private let authActionHandler: AuthWebActionHandler
	
	/// Handles successful authentication action if provided
	private var authCompletionHandler: AuthCompletionHandler?
	
	/// Handles loyalty card scanning action
	private let scanActionHandler: LoyaltyCardScanWebActionHandler
	
	/// Handles close action and flow completion
	private let closeRoute: CloseWebAuthFlowRoute
	
	/// Subject to publish url request redirections
	private let urlRequestSubject = PassthroughSubject<URLRequest, Never>()
	
	/// Web view configuration
	private(set) lazy var webViewConfiguration = cookiesManager.getConfigurationForWebView()
	
	/// Web cookies storage
	@Injectable private var cookiesManager: CookiesManager
	
	init(authRequest: URLRequest, authActionHandler: AuthWebActionHandler, scanActionHandler: LoyaltyCardScanWebActionHandler, authCompletionHandler: AuthCompletionHandler?, closeRoute: CloseWebAuthFlowRoute) {
		self.authRequest = authRequest
		self.authActionHandler = authActionHandler
		self.scanActionHandler = scanActionHandler
		self.authCompletionHandler = authCompletionHandler
		self.closeRoute = closeRoute
	}
	
	// MARK: Web view configuration
	
	var shouldPopKeyboardOnStart: Bool {
		!cookiesManager.isEmpty // Don't show keyboard on log in (no stored cookies)
	}
	
	var urlRequestPublisher: AnyPublisher<URLRequest, Never> {
		Just(authRequest)
			.merge(with: urlRequestSubject)
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
	
	// MARK: Navigation action handling
	
	/// Handles web view navigation action. Returns `true` if it was handled.
	func handleNavigationAction(with urlRequest: URLRequest) async -> Bool {
		for handler in [handleAuthenticateAction] where await handler(urlRequest) {
			return true // Action was handled
		}
		return false
	}
	
	// MARK: Authentication handler
	
	/// Handles authenticate navigation action.
	private func handleAuthenticateAction(with urlRequest: URLRequest) async -> Bool {
		do {
			guard let authToken = try await authActionHandler.handleWebAction(with: urlRequest) else { return false }
			await authCompletionHandler?.handleCompletionAction(with: authToken)
			await saveWebCookies() // Save cookies on success
			closeRoute.close(with: .success(authToken))
		} catch {
			closeRoute.close(with: .failure(error))
		}
		
		return true
	}
	
	@MainActor func saveWebCookies() async {
		let cookies = await webViewConfiguration.websiteDataStore.httpCookieStore.allCookies()
		cookiesManager.saveCookies(cookies)
	}
	
	// MARK: Close action
	
	/// Close action.
	func close() {
		closeRoute.close(with: .failure(AuthManagerError.cancelledByUser))
	}
	
}
