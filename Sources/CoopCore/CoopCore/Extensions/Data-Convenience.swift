//
// Created by Roland Leth on 26/08/2019.
// Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

public extension Data {

	/// Attempts to transform `self` into a `String`, using `utf8` encoding.
	var string: String? {
		return String(data: self, encoding: .utf8)
	}

}
