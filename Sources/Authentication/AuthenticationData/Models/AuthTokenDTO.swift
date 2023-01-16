//
//  Models.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 01.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import AuthenticationDomain

class AuthTokenDTO: NSObject, NSSecureCoding, Decodable {

	static let supportsSecureCoding: Bool = true
	
	private enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case idToken = "id_token"
		case expiresIn = "expires_in"
		case refreshToken = "refresh_token"
		case tokenGrantedTimestamp
	}
	
	private let accessToken: String
	private let idToken: String?
	private let expiresIn: Int?
	private let refreshToken: String?
	private let tokenGrantedTimestamp: Date
	
	// Mapping from and to Domain model
	
	init(authToken: AuthToken) {
		accessToken = authToken.accessToken
		idToken = authToken.idToken?.rawValue
		expiresIn = authToken.expiresIn
		refreshToken = authToken.refreshToken
		tokenGrantedTimestamp = authToken.tokenGrantedTimestamp
	}
	
	func convertToDO() -> AuthToken {
		AuthToken(accessToken: accessToken,
				  idToken: idToken,
				  expiresIn: expiresIn,
				  refreshToken: refreshToken,
				  tokenGrantedTimestamp: tokenGrantedTimestamp
		)
	}
	
	required init( from decoder: Decoder ) throws {
		let container = try decoder.container( keyedBy: CodingKeys.self )
		
		accessToken = try container.decode( String.self, forKey: .accessToken )
		idToken = try? container.decode( String.self, forKey: .idToken )
		expiresIn = try? container.decode( Int.self, forKey: .expiresIn )
		refreshToken = try? container.decode( String.self, forKey: .refreshToken )
		tokenGrantedTimestamp = Date()
	}
	
	// MARK: - NSCoding
	
	func encode( with coder: NSCoder ) {
		coder.encode( accessToken, forKey: CodingKeys.accessToken.rawValue )
		coder.encode( idToken, forKey: CodingKeys.idToken.rawValue )
		coder.encode( expiresIn, forKey: CodingKeys.expiresIn.rawValue )
		coder.encode( refreshToken, forKey: CodingKeys.refreshToken.rawValue )
		coder.encode( tokenGrantedTimestamp, forKey: CodingKeys.tokenGrantedTimestamp.rawValue )
	}
	
	required init?( coder: NSCoder ) {
		guard let accessToken = coder.decodeObject(of: NSString.self, forKey: CodingKeys.accessToken.rawValue) else {
			return nil
		}
		
		self.accessToken = accessToken as String
		idToken = coder.decodeObject(of: NSString.self, forKey: CodingKeys.idToken.rawValue) as String?
		expiresIn = coder.decodeObject(of: NSNumber.self, forKey: CodingKeys.expiresIn.rawValue)?.intValue
		refreshToken = coder.decodeObject(of: NSString.self, forKey: CodingKeys.refreshToken.rawValue) as String?
		
		if let tokenGrantedTimestamp = coder.decodeObject(of: NSDate.self, forKey: CodingKeys.tokenGrantedTimestamp.rawValue) {
			self.tokenGrantedTimestamp = tokenGrantedTimestamp as Date
		} else {
			self.tokenGrantedTimestamp = .distantPast
		}
	}
	
	override var hash: Int {
		return accessToken.hashValue
	}
	
	override func isEqual(_ object: Any?) -> Bool {
		guard let comparingToken = object as? AuthTokenDTO else { return false }
		return self.accessToken == comparingToken.accessToken
	}
}
