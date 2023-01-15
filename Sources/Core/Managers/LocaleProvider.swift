//
//  LocaleProvider.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 03.09.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public protocol LocaleProvider {
	var appLocale: Locale { get }
	var timeZone: TimeZone { get }
}
