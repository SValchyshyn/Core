//
//  HTMLViewController.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 22/06/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import Core
import Log

// TODO: refactor HTMLViewController to not use Coop authorization -IZ
open class HTMLViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate, HelpHtmlAlertViewController {
	open var contentInset: CGFloat {
		return 60
	}

	@IBOutlet weak var containerView: UIView!
	var webView: WKWebView!		// Created on viewDidLayoutSubviews

	/// URL for the content to be displayed in the web view.
	public var contentURL: URL?
	public var subscriptionKey: String?
	var isZoomAllowed = false

	// Flag used for adding the web view only once
	private var didInitialLayout = false

	@Injectable
	var userProvider: UserSessionInfoProvider
	
	override public func viewDidLayoutSubviews() {
		// Did we add the web view already?
		if !didInitialLayout {
			// No: Create the web view. It's currently not possible to add a WKWebView from Interface Builder.
			webView = WKWebView( frame: containerView.bounds )
			containerView.addSubview( webView )
			webView.navigationDelegate = self
			webView.scrollView.delegate = self

			// Add contnet inset to the web view's scroll view and scroll view indicator
			webView.scrollView.contentInset = UIEdgeInsets( top: contentInset, left: 0, bottom: 0, right: 0 )
			webView.scrollView.scrollIndicatorInsets = UIEdgeInsets( top: contentInset, left: 0, bottom: 0, right: 0 )

			// Do we have a content URL?
			if let contentURL = self.contentURL {
				// Yes: Load the content in the web view
				var request = URLRequest( url: contentURL )

				// Add a subscription key if necessary
				if let subscriptionKey = subscriptionKey {
					request.addValue( subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key" )
				}

				// Add an authorization header
				if let authenticationTokenString = userProvider.lowSecurityToken {
					request.addValue( "Bearer \(authenticationTokenString)", forHTTPHeaderField: "Authorization" )
				} else if CoreConfiguration.current == .debug {
					// Debug config only: If we don't have an auth token, we'll add "jens@greenerpastures.dk:nyhavn16" as HTTP basic auth. -JWJ
					request.addValue( "Basic amVuc0BncmVlbmVycGFzdHVyZXMuZGs6bnloYXZuMTY=", forHTTPHeaderField: "Authorization" )
				}

				webView.loadWithTracking( request )
			} else {
				// No: Log it as an error
				Log.technical.log(.error, "Error: HTMLViewController without content URL", [.identifier("CoreUserInterface.HTMLViewController.viewDidLayoutSubviews")])
			}

			// Update the flag
			didInitialLayout = true
		}
	}

	public func viewForZooming( in: UIScrollView ) -> UIView? {
		if !isZoomAllowed {
			// Disable zooming in webView
			return nil
		} else {
			return webView
		}
	}

	// MARK: - Actions

	@IBAction open func closeAction( _ sender: AnyObject ) {
		dismiss( animated: true )
	}

	// MARK: - WKNavigationDelegate

	open func webView( _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void ) {
		// Did the user tap on a link?
		if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
			// Yes: Open the URL in Safari view controller if it is http/https. Otherwise, see if UIApplication can handle it
			if url.isHttpUrl {
				let safariViewController = SFSafariViewController( url: url )
				present( safariViewController, animated: true )
			} else if UIApplication.shared.canOpenURL( url ) {
				UIApplication.shared.open( url, options: [:], completionHandler: nil )
			} else {
				Log.technical.log(.notice, "Ignoring unsupported URL: \(url.absoluteString)", [.identifier("CoreUserInterface.HTMLViewController.webView")])
			}

			// Cancel the opening of the link in the web view
			decisionHandler( .cancel )
			return
		}

		decisionHandler( .allow )
	}
}
