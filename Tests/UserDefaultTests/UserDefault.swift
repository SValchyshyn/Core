//
//  UserDefault.swift
//  UserDefaultTests
//
//  Created by Adrian Ilie on 20.06.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import XCTest

@testable import UserDefault

class TestUserDefault: XCTestCase {
	/**
	 Test UserDefaults clear storage.
	 */
	func testClear() {
		// set test data
		UserDefaults.appSettings.setObject(1, forKey: "TestKey")
		XCTAssertEqual(try? UserDefaults.appSettings.getObject(forKey: "TestKey"), 1)
		
		// test clear
		UserDefaults.appSettings.clear()
		XCTAssertNil(try? UserDefaults.appSettings.getObject(forKey: "TestKey"))
	}
}
