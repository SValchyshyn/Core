//
//  CommonStringsProtocol.swift
//  CoreUserInterface
//
//  Created by Stepan Valchyshyn on 30.09.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public protocol CommonStringsProtocol {
	var genCurrencyAbbreviated: String { get }
	var genErrorBody: String { get }
	var genErrorTitle: String { get }
	var genOK: String { get }
	var genCancel: String { get }
	var buttonRetry: String { get }
	var buttonAgree: String { get }
	var buttonDeny: String { get }
}
