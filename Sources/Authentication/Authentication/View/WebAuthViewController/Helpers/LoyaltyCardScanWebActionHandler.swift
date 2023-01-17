//
//  LoyaltyCardScanWebActionHandler.swift
//  Authentication
//
//  Created by Olexandr Belozierov on 19.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit
import Core
import CoopCore
import CoreUserInterface

struct LoyaltyCardScanWebActionHandler {
	
	private enum Constants {
		static let scanLoyaltyCardHost = "auth-scanner"
		static let returnUrlQueryItemName = "return_url"
		static let codeQueryItemName = "code"
	}
	
	enum RegistrationResult {
		case redirect(URLRequest)
		case cancelled
	}
	
	@FeatureStatusProperty(key: AuthenticationFeature.loyaltyCardScanner, defaultStatus: .disabled)
	private var loyaltyCardScannerFeatureStatus: FeatureStatus
	
	private weak var presenter: UIViewController?
	
	init(presenter: UIViewController) {
		self.presenter = presenter
	}
	
	// MARK: Validation
	
	private func returnURL(for actionURL: URL) -> URL? {
		guard actionURL.scheme == PlatformConstants.scheme,
			  actionURL.host == Constants.scanLoyaltyCardHost else { return nil }
		return actionURL.queryValue(for: Constants.returnUrlQueryItemName).flatMap(URL.init(string:))
	}	
}

private extension URL {
	
	func queryValue(for name: String) -> String? {
		URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems?.first { $0.name == name }?.value
	}
	
	mutating func setQueryValue(_ value: String, for name: String) {
		guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return }
		
		var queryItems = components.queryItems ?? []
		queryItems.append(.init(name: name, value: value))
		components.queryItems = queryItems
		
		guard let url = components.url else { return }
		self = url
	}
	
}
