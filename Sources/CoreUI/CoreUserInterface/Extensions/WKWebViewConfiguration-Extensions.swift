//
//  WKWebView-Extensions.swift
//  CoopM16
//
//  Created by Peter Antonsen on 08/07/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import WebKit

public extension WKWebViewConfiguration {
	/// A `WKWebViewConfiguration` that injects JavaScript code used to scale the content
	/// to the device width. The JavaScript code is inserted at the end of the document and applies this
	/// just for the main frame only.
	static var contentScaling: WKWebViewConfiguration {
		// Create the JavaScript code that forces the content's width to be the same as the device-width.
		let contentScalingJavaScript = """
			var meta = document.createElement('meta');
			meta.setAttribute('name', 'viewport');
			meta.setAttribute('content', 'width=device-width');
			document.getElementsByTagName('head')[0].appendChild(meta);
		"""

		// Wrap the JavaScript code into a WKUserScript. Insert at the end of the document and in the main frame only.
		let userScript = WKUserScript( source: contentScalingJavaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true )
		let wkUController = WKUserContentController()
		wkUController.addUserScript( userScript)
		let wkWebConfig = WKWebViewConfiguration()
		wkWebConfig.userContentController = wkUController

		return wkWebConfig
	}
}
