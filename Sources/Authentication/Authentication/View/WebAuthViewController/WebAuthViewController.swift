//
//  WebAuthViewController.swift
//  Authentication
//
//  Created by Olexandr Belozierov on 18.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Combine
import UIKit
import WebKit
import Core
import CoreUserInterface
import Tracking

/// Class that is used for default theme injection for `WebAuthViewController`
public class WebAuthViewControllerTheme: CorePlatformWebFeatureViewController.Theme {}

class WebAuthViewController: CorePlatformWebFeatureViewController, Trackable {
	
	// MARK: - Trackable
	
	let trackingPageId = "auth_user_login"
	let trackingPageName = "auth_user_login"
	
	var viewModel: WebAuthViewModel!
	private var subscriptions = [AnyCancellable]()
	
	// MARK: Configs

	override var configuration: WKWebViewConfiguration? {
		viewModel.webViewConfiguration
	}
	
	override var shouldPopKeyboardOnStart: Bool {
		viewModel.shouldPopKeyboardOnStart
	}
	
	override func webViewClose() {
		viewModel.close()
	}
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Show spinner before loaded state
		showLoadingSpinner(animated: true)
		
		configureUI()
		bindViews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		trackViewController(parameters: nil)
	}
	
	// MARK: Configuration
	
	private func configureUI() {
		if let theme: WebAuthViewControllerTheme = ServiceLocator.injectSafe() {
			self.theme = theme // update with custom theme
		}
	}
	
	private func bindViews() {
		viewModel.urlRequestPublisher
			.sink(receiveValue: webView.loadWithTracking)
			.store(in: &subscriptions)
	}
	
	// MARK: - WKNavigationDelegate
	
	override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
		let policy = await super.webView(webView, decidePolicyFor: navigationAction)

		// Try to handle navigation action if it wasn't handled by super implementation
		if policy == .allow, await viewModel.handleNavigationAction(with: navigationAction.request) {
			return .cancel // Cancel if it was handled
		}

		return policy
	}
	
}
