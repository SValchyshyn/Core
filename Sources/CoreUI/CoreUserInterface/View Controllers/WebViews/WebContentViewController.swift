//
//  WebContentViewController.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 04/06/2018.
//  Copyright © 2018 Greener Pastures. All rights reserved.
//

import UIKit
import WebKit
import Core

open class WebContentViewController: WebKitViewController {

	private enum Constants {
		/// Query parameter for the hashed member ID
		static let queryParameterUserID = "user_id"

		// The size of the close button
		static let closeButtonSize = CGSize( width: 60, height: 40 )

		// Spacing between the close button and the top safe area
		static let closeButtonTopOffset: CGFloat = 2

		static let closeButtonBackground = UIColor(white: 1, alpha: 0.84)

	}

	private lazy var closeButton: CloseButton = {
		var closeButton = CloseButton( frame: .zero )
		closeButton.circleColor = Constants.closeButtonBackground
		closeButton.isHidden = hideCloseButton
		closeButton.addTarget( self, action: #selector( closeAction ), for: .touchUpInside )
		return closeButton
	}()

	/// An URL to load
	public var url: URL

	/// A URL prefix on which the page should close by itself
	public var callback: String?

	/// Send user data with the URL if true
	public var sendUserInfo: Bool = false

	public var queryParameters: [ URLQueryItem ] = []

	/// If true, the close button will be hidden
	public var hideCloseButton: Bool = true {
		didSet {
			closeButton.isHidden = hideCloseButton
		}
	}

	/// Property for modifying the close button background color if needed
	public var closeButtonBackground: UIColor = Constants.closeButtonBackground {
		didSet {
			closeButton.circleColor = closeButtonBackground
		}
	}

	/// If false, the pinch gesture will be disabled
	public var userCanZoom: Bool = true
	
	@InjectableSafe
	var userProvider: UserSessionInfoProvider?

	public init(url: URL, callback: String? = nil, sendUserInfo: Bool = false, queryParameters: [URLQueryItem] = [], hideCloseButton: Bool = true, userCanZoom: Bool = true ) {
		// Set required properites
		self.url = url

		// Set optional prperties
		self.callback = callback
		self.sendUserInfo = sendUserInfo
		self.queryParameters = queryParameters
		self.hideCloseButton = hideCloseButton
		self.userCanZoom = userCanZoom
		super.init(nibName: nil, bundle: nil)
	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	open override func viewDidLoad() {
		super.viewDidLoad()
		
		// Configure the close button and its constraints
		setupCloseButton()

		// Send the web kit view back, otherwise it hides the close button
		view.sendSubviewToBack( webView )

		// Load the url
		showLoadingSpinner( animated: true )

		var finalURL = url

		// Add the member ID to the URL if required
		let urlComponents = NSURLComponents( string: url.absoluteString )

		if sendUserInfo, let userProvider = userProvider, let hashedMemberID = userProvider.hashedMemberId {
			queryParameters.append( URLQueryItem( name: Constants.queryParameterUserID, value: hashedMemberID ) )
		}

		if urlComponents?.queryItems != nil {
			urlComponents?.queryItems?.append(contentsOf: queryParameters)
		} else if !queryParameters.isEmpty {
			urlComponents?.queryItems = queryParameters
		}
		finalURL = urlComponents?.url ?? url

		webView.loadWithTracking( URLRequest( url: finalURL ))
	}

	private func setupCloseButton() {
		// Configure the layout constraints for the close button
		view.addSubview( closeButton )
		closeButton.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate( [
			closeButton.trailingAnchor.constraint( equalTo: view.safeAreaLayoutGuide.trailingAnchor ),
			closeButton.topAnchor.constraint( equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.closeButtonTopOffset ),
			closeButton.widthAnchor.constraint( equalToConstant: Constants.closeButtonSize.width ),
			closeButton.heightAnchor.constraint( equalToConstant: Constants.closeButtonSize.height )
		])
	}

	// MARK: - WKNavigationDelegate

	@objc open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void ) {
		if let url = navigationAction.request.url, let callback = callback, url.absoluteString.hasPrefix( callback ) {
			self.presentingViewController?.dismissAllPresentedViewControllers( animated: true )
				decisionHandler( .cancel )
				return
		}

		// Load the request with the web view
		decisionHandler( .allow )
	}

	@objc open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation! ) {
		// Hide spinner after successfull load
		hideLoadingSpinner( animated: true )
	}

	@objc open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error ) {
		// Hide spinner
		hideLoadingSpinner( animated: true )
	}

	// MARK: - UIScrollViewDelegate

	func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
		// Make sure to disable the zoom gesture if needed
		if !userCanZoom {
			scrollView.pinchGestureRecognizer?.isEnabled = false
		}
	}
}
