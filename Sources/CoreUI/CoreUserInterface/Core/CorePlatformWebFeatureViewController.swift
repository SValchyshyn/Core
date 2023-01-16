//
//  CorePlatformWebFeatureViewController.swift
//  CoreUserInterface
//
//  Created by Stepan Valchyshyn on 25.09.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit
import WebKit

/// Common class for web features. Includes common toolbar on top, launching `goBack` js script on dismiss, self updating title and more.
open class CorePlatformWebFeatureViewController: WebKitViewController {
	
	private enum Constants {
		static let closeWebViewCallback = "callback://close"
		static let webViewGoBackScript = "(function() { try { return window.goBack({ version: 2 }) } catch (e) { window.location = '\(closeWebViewCallback)'; throw e } })();"
	}
	
	/// Class with colors and fonts theme for controller
	open class Theme {
		
		static let `default` = Theme(
			viewBackgroundColor: colorsContent.colorBackground,
			topBarBackgroundColor: colorsContent.colorBackground,
			titleLabelTextColor: colorsContent.bodyTextColor,
			titleLabelFont: fontProvider.H5HeaderFont)
		
		/// Background color for view
		public let viewBackgroundColor: UIColor
		
		/// Background color for top bar
		public let topBarBackgroundColor: UIColor
		
		/// Font and text color for title label
		public let titleLabelTextColor: UIColor
		public let titleLabelFont: UIFont
		
		public init(
			viewBackgroundColor: UIColor,
			topBarBackgroundColor: UIColor,
			titleLabelTextColor: UIColor,
			titleLabelFont: UIFont) {
			self.viewBackgroundColor = viewBackgroundColor
			self.topBarBackgroundColor = topBarBackgroundColor
			self.titleLabelTextColor = titleLabelTextColor
			self.titleLabelFont = titleLabelFont
		}
	}
	
	// MARK: - Outlets
	
	@IBOutlet weak var closeButton: CloseButton!
	@IBOutlet weak var titleLabel: UILabel?
	
	// TODO: Reenable on Samkaup app v2 release -SV
	/// `WebViewKeyboardAppearer` instance to enable automatically showing keyboard for `WKWebview`
	private var webviewKeyboardAppearer: WebViewKeyboardAppearer = .init()
	
	/// `NSKeyValueObservation` token.
	private var _kvoToken: NSKeyValueObservation?
	
	/// A flag whether we should show the keyboard right away on page load
	open var shouldPopKeyboardOnStart: Bool {
		return false
	}
	
	/// Theme for colors and fonts
	public var theme: Theme = .default {
		didSet { configureColorsAndFonts() }
	}

	open override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set delegates
		webView.navigationDelegate = self
		
		observeTitleChange()
		setupView()
		configureColorsAndFonts()
	}
	
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if shouldPopKeyboardOnStart {
			webviewKeyboardAppearer.setKeyboardRequiresUserInteraction( false )
		} else {
			addEnterForegroundObserver()
		}
	}
	
	open override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		webviewKeyboardAppearer.resetAutomaticKeyboardAppearance()
		removeEnterForegroundObserver()
	}
	
	// MARK: - Deinitialization
	
	deinit {
		// Invalidate observation in deinit.
		_kvoToken?.invalidate()
	}
	
	open func webViewClose() {
		dismiss(animated: true)
	}
	
	open func webViewFailNavigation() {
		showErrorAlert()
	}
	
	open override func closeAction() {
		// Dismiss button acts as a `go back` web action if possible. Trigger `goBack` script and check for result. If result is nil and no error - we are on the last page and can safely dismiss the webView. If result is a close webview callback - treat as corresponds. Else do nothing and just listen to redirects.
		webView.evaluateJavaScript(Constants.webViewGoBackScript) { _, error in
			if error != nil { self.webViewClose() }
		}
	}
	
	private func observeTitleChange() {
		// Start listening for web title changes
		_kvoToken = webView.observe( \.title, options: [.new] ) { [weak self] _, value in
			if let title = value.newValue {
				// Update native title label with the one, taken from the web page
				self?.titleLabel?.text = title
			}
		}
	}
	
	private func setupView() {
		// Send the web kit view back, otherwise it hides the close button
		view.sendSubviewToBack( webView )
		
		webView.scrollView.showsVerticalScrollIndicator = false
	}
	
	private func configureColorsAndFonts() {
		viewIfLoaded?.backgroundColor = theme.viewBackgroundColor
		
		titleLabel?.font = theme.titleLabelFont
		titleLabel?.textColor = theme.titleLabelTextColor
		
		topBarView?.backgroundColor = theme.topBarBackgroundColor
	}
	
	// MARK: - WKNavigationDelegate
	
	@objc open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation! ) {
		// Hide spinner after successfull load
		hideLoadingSpinner( animated: true )
	}
	
	@objc open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error ) {
		// Hide spinner
		hideLoadingSpinner( animated: true )
		
		webViewFailNavigation()
	}
	
	@objc open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
		if navigationAction.request.url?.absoluteString == Constants.closeWebViewCallback {
			webViewClose()
			return .cancel
		}

		return .allow
	}
	
	private func showErrorAlert() {
		// OK action
		let topAction = CustomAlertAction.okAction { _ in
			// Dismiss the view controller since it is useless without data
			self.webViewClose()
		}
		
		// Create and show the alert
		let alert = BasicAlertViewController( title: commonContent.genErrorTitle, message: commonContent.genErrorBody, topAction: topAction, bottomAction: nil, presentationStyle: .fullWidth )
		present( alert, animated: true )
	}
	
	// MARK: Foreground state observer
	
	/// Add notification for force endEditing of webView, if keyboard present after app becomes foreground for these types
	private func addEnterForegroundObserver() {
		NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
	}
	
	private func removeEnterForegroundObserver() {
		NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
	}
	
	@objc private func willEnterForeground() {
		webView.window?.endEditing(true)
	}
	
}
