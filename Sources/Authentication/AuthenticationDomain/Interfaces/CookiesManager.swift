//
//  CookiesManager.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 20.11.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import WebKit

public protocol CookiesManager {
	/// Check if manager contains cookies
	var isEmpty: Bool { get }
	/// Append necessary cookies to `URLRequest`. Return any additional cookies to attach while URL redirect session
	func appendCookies( to request: URLRequest ) -> ( URLRequest, Set<HTTPCookie> )
	/// Prepare `WKWebViewConfiguration` with all necessary cached data to be applied  to`WKWebView`
	func getConfigurationForWebView() -> WKWebViewConfiguration
	/// Persist new auth cookies
	func saveCookies( _ cookies: [ HTTPCookie ])
	/// Persist new auth cookies retrieved during redirect chain
	func saveIntermediateCookies( _ cookies: [ HTTPCookie ])
	/// Clear cached cookies
	func clearCookies()
}
