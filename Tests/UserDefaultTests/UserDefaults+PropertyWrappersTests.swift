//
//  UserDefaults+PropertyWrappersTests.swift
//  UserDefaultTests
//
//  Created by Frederik Sørensen on 15/11/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import XCTest
import Foundation

@testable import UserDefault

struct Person: Codable, Equatable {
	let name: String
}

class UserDefaultsPropertyWrappersTests: XCTestCase {
	struct Constants {
		static let simpleKey = "SomeNeverUsedKey"
		static let codableKey = "SomeNeverUsedCodableKey"
		static let oldKey = "OldKey"
	}

	enum UserSettings {
		@UserDefault( key: Constants.simpleKey, defaultValue: false )
		static var someNeverUsedValue: Bool // Stored in userSettings

		@CodableUserDefault( key: Constants.codableKey, defaultValue: nil )
		static var person: Person? // Stored in userSettings

		@UserDefault( key: Constants.simpleKey, defaultValue: "", shouldClearOnLogout: false )
		static var redundantValueInOtherStorage: String // Stored in appSettings

		@UserDefault( key: Constants.simpleKey, defaultValue: nil, migration: Migration( key: Constants.oldKey ) )
		static var saveNil: String?
	}

	override func tearDownWithError() throws {
		try super.tearDownWithError()

		UserDefaults.appSettings.clear()
		UserDefaults.userSettings.clear()
	}

	func testStoringValuesInDefaults() {
		XCTAssertFalse( UserSettings.someNeverUsedValue, "Expected test to start with the default value" )
		UserSettings.someNeverUsedValue = true
		XCTAssertTrue( UserSettings.someNeverUsedValue, "Expected test to have new stored value" )
	}

	func testStoringCodableValuesInDefaults() {
		XCTAssertNil( UserSettings.person, "Expected person to be nil at first" )
		let person = Person( name: "Cool Name" )
		UserSettings.person = person
		XCTAssertEqual( UserSettings.person, person, "Expected stored value and memory value to be the same" )
	}

	func testStoringValuesInDifferentDefaults() {
		XCTAssertEqual( UserSettings.redundantValueInOtherStorage, "", "Expected the default value to be an empty string" )
		UserSettings.redundantValueInOtherStorage = "New Value"
		XCTAssertEqual( UserSettings.redundantValueInOtherStorage, "New Value", "Expected the stored value to be the assigned value" )

		XCTAssertFalse( UserSettings.someNeverUsedValue, "Still expect the value to be false" )
		UserSettings.someNeverUsedValue = true
		XCTAssertTrue( UserSettings.someNeverUsedValue, "Expect to still be able to write to the other storage without interference" )

		XCTAssertEqual( UserSettings.redundantValueInOtherStorage, "New Value", "Still expect the value to be the assigned value" )
	}

	func testStoringValuesInDifferentDefaultsDoesntClear() {
		// CoopStore a value in userSettings
		UserSettings.redundantValueInOtherStorage = "New Value"
		XCTAssertEqual( UserSettings.redundantValueInOtherStorage, "New Value", "Expected the stored value to be the assigned value" )

		// CoopStore a value in appSettings
		UserSettings.someNeverUsedValue = true
		XCTAssertTrue( UserSettings.someNeverUsedValue, "Expect to still be able to write to the other storage without interference" )

		// Clear the values in userSettings
		for key in UserDefaults.userSettings.dictionaryRepresentation().keys {
			UserDefaults.userSettings.removeObject( forKey: key )
		}

		// Write the changes to disk
		UserDefaults.userSettings.synchronize()

		// Assert that the userSettings value has been removed and that the appSettings value is still there
		XCTAssertFalse( UserSettings.someNeverUsedValue, "The value in userSettings should have been cleared and therefore reset" )
		XCTAssertEqual( UserSettings.redundantValueInOtherStorage, "New Value", "The value in appSettings should be the same" )
	}

	func testSavingNil() {
		UserSettings.person = nil

		XCTAssertNil( UserSettings.person )

		UserSettings.saveNil = nil
		XCTAssertNil( UserSettings.saveNil )
	}

	func testSimpleMigration() {
		enum LocalUserSettings {
			@UserDefault( key: Constants.simpleKey, defaultValue: nil, migration: Migration( key: Constants.oldKey ) )
			static var valueToMigrate: String?
		}

		let value = "ValueToBeMigrated"

		XCTAssertNil( UserDefaults.userSettings.string( forKey: Constants.simpleKey ), "Expected the value to be cleared before accessing" )
		XCTAssertNil( UserDefaults.standard.string( forKey: Constants.oldKey ), "Expect the value to not be present" )

		// Set a value
		UserDefaults.standard.set( value, forKey: Constants.oldKey )
		XCTAssertEqual( UserDefaults.standard.string( forKey: Constants.oldKey ), value, "Value should now be stored in `.standard`" )

		XCTAssertEqual( LocalUserSettings.valueToMigrate, value, "Value should be fetched from `.standard` and moved to `.userSettings`" )
		XCTAssertEqual( UserDefaults.userSettings.string( forKey: Constants.simpleKey ), value, "Should be stored under the new key" )
		XCTAssertNil( UserDefaults.standard.string( forKey: Constants.oldKey ), "Value should be cleared from `.standard`" )
	}

	func testSimpleMigrationFromEmptyValueNotOverridingExistingValue() {
		enum LocalUserSettings {
			@UserDefault( key: Constants.simpleKey, defaultValue: nil, migration: Migration( key: Constants.oldKey ) )
			static var valueToMigrate: String?
		}

		let value = "InitiallyStoredValue"

		XCTAssertNil( UserDefaults.userSettings.string( forKey: Constants.simpleKey ), "Expect the value to not to be present" )
		XCTAssertNil( UserDefaults.standard.string( forKey: Constants.oldKey ), "Expect the value to not to be present" )

		// Set existing value
		UserDefaults.userSettings.set( value, forKey: Constants.simpleKey )

		XCTAssertEqual( LocalUserSettings.valueToMigrate, value, "nil value from `.standard` should not override existing value in `.userSettings`" )
		XCTAssertEqual( UserDefaults.userSettings.string( forKey: Constants.simpleKey ), value, "Value should still be present after migration" )
	}

	func testCodableMigration() {
		enum LocalUserSettings {
			@CodableUserDefault( key: Constants.codableKey, defaultValue: nil, migration: Migration( key: Constants.oldKey ) )
			static var personToMigrate: Person?
		}

		let value = Person( name: "I should be migrated" )

		guard let data = try? JSONEncoder().encode( value ) else {
			XCTFail( "Could not encode person?" )
			return
		}

		XCTAssertNil( UserDefaults.userSettings.data( forKey: Constants.codableKey ), "Expected the value to be cleared before accessing" )
		XCTAssertNil( UserDefaults.standard.data( forKey: Constants.oldKey ) )

		UserDefaults.standard.set( data, forKey: Constants.oldKey )

		XCTAssertEqual( UserDefaults.standard.data( forKey: Constants.oldKey ), data, "Value should now be stored in `.standard`" )

		XCTAssertEqual( LocalUserSettings.personToMigrate, value, "Value should be fetched from `.standard` and moved to `.userSettings`" )
		XCTAssertEqual( UserDefaults.userSettings.data( forKey: Constants.codableKey ), data, "Should be stored under the new key" )
		XCTAssertNil( UserDefaults.standard.data( forKey: Constants.oldKey ), "Value should be cleared from `.standard`" )
	}

	func testCodableMigrationFromEmptyValueNotOverridingExistingValue() {
		enum LocalUserSettings {
			@CodableUserDefault( key: Constants.codableKey, defaultValue: nil, migration: Migration( key: Constants.oldKey ) )
			static var personToMigrate: Person?
		}

		let value = Person( name: "InitiallyStoredValue" )

		guard let data = try? JSONEncoder().encode( value ) else {
			XCTFail( "Could not encode person" )
			return
		}

		XCTAssertNil( UserDefaults.userSettings.data( forKey: Constants.codableKey ), "Expect the value to not to be present" )
		XCTAssertNil( UserDefaults.standard.data( forKey: Constants.oldKey ), "Expect the value to not to be present" )

		// Set existing value
		UserDefaults.userSettings.set( data, forKey: Constants.codableKey )

		XCTAssertEqual( LocalUserSettings.personToMigrate, value, "nil value from `.standard` should not override existing value in `.userSettings`" )
		XCTAssertEqual( UserDefaults.userSettings.data( forKey: Constants.codableKey ), data, "Data should still be present after migration" )
	}
}
