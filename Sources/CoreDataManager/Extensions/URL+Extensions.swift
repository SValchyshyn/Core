//
//  URL+Extensions.swift
//  CoreDataManager
//
//  Created by Olexandr Belozierov on 05.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

extension URL {
	
	func updateExcludedFromBackupValue(_ exclude: Bool) throws {
		try (self as NSURL).setResourceValue(NSNumber(value: exclude), forKey: .isExcludedFromBackupKey)
	}
	
}
