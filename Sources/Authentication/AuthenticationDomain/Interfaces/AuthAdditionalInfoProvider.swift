//
//  AuthAdditionalInfoProvider.swift
//  Authentication
//
//  Created by Andriy Tkach on 13.01.2023.
//  Copyright © 2023 Loop By Coop. All rights reserved.
//

import Foundation

public protocol AuthAdditionalInfoProvider {
	
	var userID: String? { get }
	
}
