//
//  WebPlayerViewController.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 07.09.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit
import WebKit

public class WebPlayerViewController: WebKitViewController {
	private struct Constants {
		/// Margin between the close button and the edge of the screen
		static let closeButtonMargin: CGFloat = 16.0
		static let closeButtonSize: CGSize = CGSize( width: 60, height: 40 )
	}

	/// The loaded url
	private var url: URL

	/// Should we show a close button?
	private var showCloseButton: Bool

	// MARK: Initialization
	public init(url: URL, showCloseButton: Bool = false) {
		self.url = url
		self.showCloseButton = showCloseButton
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override var configuration: WKWebViewConfiguration? {
		let configuration = WKWebViewConfiguration()
		configuration.allowsInlineMediaPlayback = true
		configuration.mediaTypesRequiringUserActionForPlayback = []
		return configuration
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		loadUrlToWebView()
		addCloseButtonIfNeeded()
	}

	public override var prefersStatusBarHidden: Bool {
		return true
	}
	
	/// Load controller's url into webView
	private func loadUrlToWebView() {
		let videoType = VideoType(urlString: url.absoluteString)
		
		switch videoType {
		case .mp4:
			webView.load(URLRequest(url: url))
		
		case .html:
			guard let allowInlineUrl = url.addingPlaysInlined() else {
				return
			}
			let request = URLRequest(url: allowInlineUrl)
			webView.load(request)
		}
	}

	/**
	Configure and insert a close button
	*/
	private func addCloseButtonIfNeeded() {
		guard showCloseButton else {
			return
		}

		let closeButton = CloseButton()
		view.addSubview( closeButton )

		// Setup constraints for the close button
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate( [
			closeButton.widthAnchor.constraint( equalToConstant: Constants.closeButtonSize.width ),
			closeButton.heightAnchor.constraint( equalToConstant: Constants.closeButtonSize.height ),
			closeButton.trailingAnchor.constraint( equalTo: view.trailingAnchor, constant: -Constants.closeButtonMargin ),
			closeButton.topAnchor.constraint( equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0 )
		])

		// Let the superclass handle the button actions
		closeButton.addTarget( self, action: #selector(closeAction), for: .touchUpInside )
	}
}

// MARK: - WKNavigationDelegate
public extension WebPlayerViewController {
	
	@objc func webView(_ webView: WKWebView, didFinish navigation: WKNavigation! ) {
		// Hide spinner after successful load
		hideLoadingSpinner( animated: true )
	}
	
	@objc func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error ) {
		// Hide spinner
		hideLoadingSpinner( animated: true )
	}
		
	@objc func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void ) {
		// Load the request with the web view
		decisionHandler( .allow )
	}
}

private extension URL {
	/// Return `URL`,  which content can play inline
	func addingPlaysInlined() -> URL? {
		// Here we add `?playsinline=1"` to the end of the urlString to play automatically video after webView loads
		// https://stackoverflow.com/a/50815861/3542688
		return self.appendingQueryParameters( ["playsinline": "1"] )
	}
}

public extension URL {
	/**
	Append the given parameters to the URL

	- Parameter parameters: parameters dictionary.
	- Returns: URL with appending given query parameters.
	*/
	func appendingQueryParameters(_ parameters: [String: String]) -> URL? {
		guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
			return nil
		}

		urlComponents.queryItems = (urlComponents.queryItems ?? []) + parameters
			.map { URLQueryItem(name: $0, value: $1) }
		return urlComponents.url
	}
}
