//
//  AuthenticationURLSession.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 23.11.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import Core
import AuthenticationDomain
import Log

/// URLSession wrapper class that stores intermediate cookies and append them along the redirect chain
final class AuthenticationURLSession: NSObject {
	private enum Constants {
		static let cookieHeaderFieldName = "Cookie"
	}
	
	@Injectable private var cookiesManager: CookiesManager
	
	private var session: URLSession?
	/// Cookies that were set while performing redirect navigation
	private var intermediateCookies: Set<HTTPCookie> = []
	/// Callback to start once the `redirectURI` received
	private var redirectCallback: ( ( Result<AuthCode?, Error> ) -> Void )?
	/// Initial request to start from
	private var request: URLRequest?
	/// Auth config
	private let authConfig: AuthConfig
	
	init( authConfig: AuthConfig ) {
		self.authConfig = authConfig
		super.init()
		
		(request, intermediateCookies) = cookiesManager.appendCookies(to: URLRequest(url: authConfig.authURL))
		session = URLSession( configuration: .default, delegate: self, delegateQueue: nil )
	}
	
	/// Start the request and follow redirect chain
	func execute() async throws -> AuthCode? {
		guard !cookiesManager.isEmpty else {
			return nil // Use silent auth only if we have cookies
		}
		
		guard let request = self.request, let session = session else {
			throw URLError(.badURL)
		}
		
		return try await withCheckedThrowingContinuation { continuation in
			// Remember the callback
			redirectCallback = continuation.resume
			
			session.dataTask( with: request) { _, response, error in
				// If we get here means that `redirectURI` was not found. Return the last `uri` that was found
				if let responseUrl = response?.url {
					do {
						let authCode = try self.authConfig.authCode(for: responseUrl)?.get()
						continuation.resume(returning: authCode)
					} catch {
						continuation.resume(throwing: error)
					}
				} else {
					continuation.resume(throwing: error ?? AuthManagerError.authDataMissing)
				}
			}.resume()
		}
	}
	
	/// A wrapper to execute `redirectCallback` and clean any reference to avoid repetitive calls to `redirectCallback`
	private func executeCallback(_ with: Result<AuthCode?, Error> ) {
		if redirectCallback != nil {
			redirectCallback?(with)
			redirectCallback = nil
		} else {
			Log.technical.log(.warning, "Attempt to execute callback while it's nil with result: \(with)")
		}
	}
}

extension AuthenticationURLSession: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
	func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
		if let url = request.url, let result = authConfig.authCode(for: url) {
			do {
				// Successfuly found auth code. Fire the callback
				try executeCallback(.success(result.get()))
				cookiesManager.saveIntermediateCookies(Array(intermediateCookies))
			} catch {
				executeCallback(.failure(error))
			}
			
			// Invalidate the session before leaving the scope to prevent memory leaks
			return session.finishTasksAndInvalidate()
		}
		
		if let url = response.url, let allHeaderFields = response.allHeaderFields as? [String: String] {
			// Extract any header cookies from redirect call
			let cookies = HTTPCookie.cookies( withResponseHeaderFields: allHeaderFields, for: url )
			// Remember intermediate cookies
			for cookie in cookies {
				intermediateCookies.insert(cookie)
			}
		}
		
		let cookiesToAppend: [HTTPCookie] = intermediateCookies.filter{
			request.url?.absoluteString.contains( $0.domain ) ?? false
		}
		
		// Prepare cookies header field
		let cookieDict = HTTPCookie.requestHeaderFields( with: cookiesToAppend )
		// Mutate new request
		var newRequest = request
		if let cookieStr = cookieDict[Constants.cookieHeaderFieldName] {
			newRequest.setValue( cookieStr, forHTTPHeaderField: Constants.cookieHeaderFieldName )
		}
		
		completionHandler( newRequest )
	}
}
