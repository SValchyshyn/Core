//
//  WebKitViewController.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 31/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit
import WebKit

open class WebKitViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {
	// MARK: - Outlets.

	@IBOutlet public weak var topBarView: UIView?

	// MARK: - Public interface.

	/// The `WKWebView` in which all the content will be rendered.
	public lazy var webView: WKWebView = {
		// Create and configure the web kit view
		if let config = configuration {
			return WKWebView( frame: .zero, configuration: config )
		} else {
			return WKWebView()
		}
	}()

	/// Used to init the `WKWebView` with.
	/// Default value: `nil`.
	open var configuration: WKWebViewConfiguration? {
		return nil
	}

	// MARK: - View methods.

	open override func viewDidLoad() {
		super.viewDidLoad()

		webView.translatesAutoresizingMaskIntoConstraints = false
		
		webView.navigationDelegate = self
		webView.scrollView.delegate = self
		webView.uiDelegate = self
		
		view.addSubview( webView )

		// Configure the web kit view constraints
		webView.leftAnchor.constraint( equalTo: view.leftAnchor ).isActive = true
		webView.rightAnchor.constraint( equalTo: view.rightAnchor ).isActive = true
		webView.bottomAnchor.constraint( equalTo: view.bottomAnchor ).isActive = true

		// Constraint to the top bar if we have one, otherwise use the view's top anchor
		if let topBarView = topBarView {
			webView.topAnchor.constraint( equalTo: topBarView.bottomAnchor ).isActive = true
		} else {
			webView.topAnchor.constraint( equalTo: view.topAnchor ).isActive = true
		}
	}

	// MARK: - Actions.

	@IBAction open func closeAction() {
		dismiss( animated: true )
	}
}

extension WebKitViewController: WKUIDelegate {
	// Required to handle `_blank` redirects with external browser
	public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
		guard navigationAction.targetFrame == nil else { return nil }
		
		if let url = navigationAction.request.url {
			let shared = UIApplication.shared
			if shared.canOpenURL( url ) {
				shared.open( url, options: [:], completionHandler: nil )
			}
		}
		return nil
	}
}
