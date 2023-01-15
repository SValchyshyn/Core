//
//  DateGroupable.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 07.05.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/**
Protocol indicating that objects can be grouped by date
*/
public protocol DateGroupable {
	var groupByDate: Date { get }
}
