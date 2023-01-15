//
//  UserInfoProvider.swift
//  CoopCore
//
//  Created by Ihor Zabrotskyi on 01.03.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

/// Provides an interface for getting the memberId of current `User`. Should be used for DK and Brugseni only.
public protocol UserSessionInfoProvider: AnyObject {
	var memberId: Int? { get }
	var hashedMemberId: String? { get }
	var lowSecurityToken: String? { get }
	var highSecurityToken: String? { get }
}
