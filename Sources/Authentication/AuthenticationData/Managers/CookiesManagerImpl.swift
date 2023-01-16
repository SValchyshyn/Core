//
//  CookiesManagerImpl.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 20.11.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Core
import CoopCore
import AuthenticationDomain
import Log
import WebKit

open class CookiesManagerImpl: CookiesManager {
	public enum Constants {
		public static let cookieHeaderFieldName = "Cookie"
		public static let cookiesKeychainKey = "cookies"
		public static let processPoolKey = "processPool"
	}
	
	/// Flag indicating if we allow saving intermediate auth cookies retrieved during silent flow
	open var allowSavingIntermediateTokens: Bool {
		return false
	}
	
	public init() {}
	
	public var isEmpty: Bool {
		getCachedCookies()?.isEmpty != false
	}
	
	open func appendCookies( to request: URLRequest ) -> ( URLRequest, Set<HTTPCookie> ) {
		var newRequest = request
		
		// Get cached cookies
		if let cookies = self.getCachedCookies() {
			var cookiesArray: [HTTPCookie] = []
			
			for cookie in cookies {
				// Ignore expired cookies. They will later be overriden once renew with UI will be finished
				if let url = request.url, url.absoluteString.contains( cookie.domain ) {
					if let cookieExpireDate = cookie.expiresDate {
						if cookieExpireDate > Date() {
							cookiesArray.append(cookie)
						}
					} else {
						// If no expiration date - cookie is permanent and we can use it
						cookiesArray.append(cookie)
					}
				}
			}
			
			let cookieDict = HTTPCookie.requestHeaderFields(with: cookiesArray)
			if let cookieStr = cookieDict[Constants.cookieHeaderFieldName] {
				newRequest.setValue( cookieStr, forHTTPHeaderField: Constants.cookieHeaderFieldName )
			}
			
			// Do not return any additional cookies
			return (newRequest, [])
		} else {
			return (request, [])
		}
	}
	
	public func getConfigurationForWebView() -> WKWebViewConfiguration {
		let configuration = WKWebViewConfiguration()
		
		// Need to reuse the same process pool to achieve cookie persistence
		let processPool: WKProcessPool

		if let pool: WKProcessPool = self.getData( key: Constants.processPoolKey ) {
			processPool = pool
		} else {
			processPool = WKProcessPool()
			self.setData( processPool, key: Constants.processPoolKey )
		}

		configuration.processPool = processPool
		configuration.websiteDataStore = WKWebsiteDataStore.default()

		return configuration
	}
	
	public func saveCookies( _ cookies: [ HTTPCookie ]) {
		self.cacheCookies( cookies )
	}
	
	public func saveIntermediateCookies(_ cookies: [HTTPCookie]) {
		guard allowSavingIntermediateTokens else {
			return
		}
		
		saveCookies(cookies)
	}
	
	public func clearCookies() {
		// Remove from all cookies storages
		clearWebViewCookies()
		HTTPCookieStorage.shared.removeCookies(since: .distantPast)
		removeCookies()
	}
	
	private func clearWebViewCookies() {
		let types = WKWebsiteDataStore.allWebsiteDataTypes()
		WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: .distantPast) {}
	}
	
	private func removeCookies() {
		do {
			try Keychain.shared.deleteGenericPassword(
				account: AuthKeychainConstants.keychainAccountName,
				service: Constants.cookiesKeychainKey)
		} catch let error {
			Log.technical.log(.error, "Error deleting session cookies from keychain: \(error)", [.identifier("CookiesManagerImpl.removeCookies")])
		}
	}
}

// MARK: - UserDefaults

private extension CookiesManagerImpl {
	func setData<T: NSSecureCoding & NSObject>(_ value: T, key: String) {
		do {
			let defaults = UserDefaults.standard
			let archivedPool = try T.keychainEncoded( value )
			defaults.set(archivedPool, forKey: key)
		} catch {
			Log.technical.log(.error, "Could not archite cookie information.", [.identifier("CookiesManagerImpl.archiveCookies"), .error(error)])
		}
	}
	
	func getData<T: NSSecureCoding & NSObject>(key: String) -> T? {
		var obj: T?
		do {
			let defaults = UserDefaults.standard
			if let val = defaults.value(forKey: key) as? Data {
				obj = try T.keychainDecoded( from: val )
			}
		} catch {
			Log.technical.log(.error, "Could not archite cookie information.", [.identifier("CookiesManagerImpl.unarchiveCookies"), .error(error)])
		}
		
		return obj
	}
}

// MARK: - Keychain

public extension CookiesManagerImpl {
	func getCachedCookies() -> [ HTTPCookie ]? {
		var cookies: [ HTTPCookie ]?
		
		do {
			if let tokenData = try Keychain.shared.findGenericPasswordData( account: AuthKeychainConstants.keychainAccountName, service: Constants.cookiesKeychainKey ) {
				if let cachedCookies = try [HTTPCookie].keychainDecoded( from: tokenData ) {
					cookies = cachedCookies
				} else {
					Log.technical.log(.error, "Cached cookies cannot not be decoded.", [.identifier("CookiesManagerImpl.getCachedCookies")])
				}
			}
		} catch {
			// Fail silent. The app will still work fine (but the user need to enter his password and login once more to get new cookies).
			Log.technical.log(.error, "Error fetching cached cookies from keychain: \(error).", [.identifier("CookiesManagerImpl.getCachedCookies")])
		}
		
		return cookies
	}
	
	/// Save provided cookies in keychain
	func cacheCookies(_ cookies: [ HTTPCookie ] ) {
		// Remember cookies
		do {
			// Save cookies in the keychain
			let archive = try [HTTPCookie].keychainEncoded( cookies )
			try Keychain.shared.addOrUpdateGenericPassword( account: AuthKeychainConstants.keychainAccountName, service: Constants.cookiesKeychainKey, passwordData: archive )
		} catch {
			// Fail silent. The app will still work fine (but the user need to login again if the app is terminated).
			Log.technical.log(.error, "Error saving cookies in keychain: \(error)", [.identifier("CookiesManagerImpl.cacheCookies")])
		}
	}
}
