//
//  Core+Extensions.swift
//  Core
//
//  Created by Olexandr Belozierov on 08.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit

public extension UIDevice {

	/// Returns the current model name (i.e. `iPhone10,3`, `iPhone7,1`)
	var modelName: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		return Mirror(reflecting: systemInfo.machine).children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
	}
	
}
