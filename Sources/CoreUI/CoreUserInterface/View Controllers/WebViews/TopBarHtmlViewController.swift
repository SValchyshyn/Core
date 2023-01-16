//
//  TopBarHtmlViewController.swift
//  CoreUserInterface
//
//  Created by Andriy Tkach on 01/04/21.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Core
import WebKit
import Tracking

open class TopBarHtmlViewController: HTMLViewController, Trackable {
	
	open var topBarTitle: String?
	open var openURLHandler: ((URL) -> Bool)?
	
	public init(url: URL) {
		super.init(nibName: "TopBarHtmlViewController", bundle: Bundle(for: Self.self))
		self.contentURL = url
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Outlets
	
	@IBOutlet weak var topBarView: TopBarView!
	
	// MARK: - Trackable implementation
	
	open var trackingPageId = ""
	open var trackingPageName = ""
	
	// MARK: - Appearance configuration
	
	open override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	open override var contentInset: CGFloat {
		return 0
	}
	
	// MARK: - View methods
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		topBarView.title = topBarTitle
		
		// Add a close button target to the top bar view and show image
		topBarView.addCloseButtonTarget( self, action: #selector( closeAction(_:) ))
	}
	
	open override func viewDidAppear( _ animated: Bool ) {
		super.viewDidAppear( animated )
		
		// Page tracking
		trackViewController(parameters: nil, includeExtraInfo: false )
	}
	
	// MARK: - Actions
	
	@IBAction public override func closeAction( _ sender: AnyObject ) {
		navigationController?.popViewController( animated: false )
	}
	
	// MARK: - WKWebView
	
	// We need the `@objc` in order for the class to tell the Objective-C runtime, that we implement it, since the superclass doesn't. -FSO
	@objc func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		showLoadingSpinner( animated: true )
	}

	@objc func webView( _ webView: WKWebView, didFinish navigation: WKNavigation! ) {
		hideLoadingSpinner( animated: true )
	}
	
	open override func webView( _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void ) {
		// Did the user tap on a link?
		guard let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated else {
			// No, or we're missing a URL - what can we do? ¯\_(ツ)_/¯
			decisionHandler( .allow )
			return
		}
		
		// Cancel the opening of the link in the web view
		decisionHandler( .cancel )
		
		// Open the `url` in native browser
		guard let openURLHandler = openURLHandler, openURLHandler( url ) == false else {
			UIApplication.shared.open( url )
			return
		}
	}
	
	@objc func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		handleError( error )
	}
	
	@objc func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
		handleError( error )
	}
	
	// MARK: - Error handling
	
	private func handleError( _ error: Error ) {
		hideLoadingSpinner( animated: true )
		
		// Display an alert
		let alert: BasicAlertViewController
		let okAction = CustomAlertAction.okAction( handler: closeAction )
		
		if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
			alert = BasicAlertViewController(
				title: CoreLocalizedString( "error_network_unavailable_title" ),
				message: CoreLocalizedString( "error_network_unavailable_body" ),
				topAction: okAction,
				seeMoreMessage: error.localizedDescription
			)
		} else {
			alert = BasicAlertViewController(
				title: CoreLocalizedString( "error_generic_action_title" ),
				message: CoreLocalizedString( "error_generic_action_title" ),
				topAction: okAction,
				seeMoreMessage: error.localizedDescription
			)
		}
		
		present( alert, animated: true )
	}
}
