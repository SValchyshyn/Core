//
//  HelpHTMLViewController.swift
//  CoopM16
//
//  Created by Marius Constantinescu on 22/01/2018.
//  Copyright © 2018 Greener Pastures. All rights reserved.
//

import UIKit
import WebKit
import Tracking

public final class HelpHTMLViewController: HTMLViewController, Trackable {
	/**
	Get HelpHTMLViewController's instance.
	- parameter contentURL: 		 URL for the content to be displayed in the web view.
	- parameter subscriptionKey: 	 Optional content url subscription key.
	*/
	public static func instantiate( contentURL: URL, subscriptionKey: String? ) -> UIViewController {
		let viewController = UIStoryboard( name: "Help", bundle: Bundle( for: HelpHTMLViewController.self ) ).instantiateViewController( withIdentifier: "HelpHTMLViewController" )
		let helpViewController = viewController as! HelpHTMLViewController	// Explicit unwrap, the view controller's type must always be the same -SV
		helpViewController.contentURL = contentURL
		helpViewController.subscriptionKey = subscriptionKey
		
		return viewController
	}
	
	// MARK: - Trackable
	public let trackingPageId = "faq_details"
	public let trackingPageName = "Hjælp Details"

	@IBOutlet private weak var backButton: CloseButton!
	@IBOutlet private weak var closeButton: CloseButton!

	override public func viewDidLoad() {
		super.viewDidLoad()
		if navigationController != nil {
			// It was pushed, show a back button
			backButton.isHidden = false
			closeButton.isHidden = true
		} else {
			backButton.isHidden = true
			closeButton.isHidden = false
		}
	}

	override public func viewDidAppear( _ animated: Bool ) {
		super.viewDidAppear( animated )

		// Track page
		trackViewController( parameters: nil )
	}

	override public func closeAction(_ sender: AnyObject) {
		popOrDismiss()
	}
	
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		showLoadingSpinner(animated: true)
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		hideLoadingSpinner(animated: true)
	}
}
