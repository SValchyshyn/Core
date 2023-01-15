//
//  CoopCoreParsingTests.swift
//  CoopCoreTests
//
//  Created by Georgi Damyanov on 20/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import XCTest
import CoreData
import CoreDataManager
import CoreNetworking

@testable import Core
@testable import CoreNetworking

class CoopCoreParsingTests: XCTestCase {
	/**
	Verify that we can parse and save objects in Core Data
	*/
	func testDecodableCoreDataSaving() async {
		// Create test JSON data
		guard let jsonData = regularJSON.data( using: .utf8 ) else {
			return XCTFail( "Incorrect JSON data" )
		}

		// Create a Core Data updater with a main thread managed object context
		let coreDataUpdater = CoreDataUpdater<CoreDataTestModel>( context: CoreDataManager.shared.mainQueueManagedObjectContext )

		do {
			// Parse the test data
			let safeObjects: [SafeCoreDataDecodable<CoreDataTestModel>] =
				try await ManagedObjectDataTaskResponseDecoder(
					coreDataUpdater: coreDataUpdater,
					jsonDecoder: JSONDecoder())
				.decode(data: jsonData)
			
			let objects = safeObjects.compactMap { $0.object }

			// Assert that we got the correct number of objects
			XCTAssert( objects.count == 4)

			// Assert that all the properties are parsed
			XCTAssert( objects.compactMap { $0.id }.count == 4 )
			XCTAssert( objects.compactMap { $0.name }.count == 4 )
		} catch {
			XCTFail( "Parsing Core Data test failed: \(error)" )
		}
	}

	/**
	Verify that we can parse and save objects in Core Data when a single object in the array fails the decoding.
	*/
	func testDecodableArrayInvalidElement() async {
		// Create test JSON data
		guard let jsonData = failingElementJSON.data( using: .utf8 ) else {
			return XCTFail( "Incorrect JSON data" )
		}

		// Create a Core Data updater with a main thread managed object context
		let coreDataUpdater = CoreDataUpdater<CoreDataTestModel>( context: CoreDataManager.shared.mainQueueManagedObjectContext )

		do {
			// Parse the test data
			let safeObjects: [SafeCoreDataDecodable<CoreDataTestModel>] =
				try await ManagedObjectDataTaskResponseDecoder(
					coreDataUpdater: coreDataUpdater,
					jsonDecoder: JSONDecoder())
				.decode(data: jsonData)
			
			let objects = safeObjects.compactMap { $0.object }

			// Assert that we got the correct number of objects
			XCTAssert( objects.count == 3)

			// Assert that all the properties are parsed
			XCTAssert( objects.compactMap { $0.id }.count == 3 )
			XCTAssert( objects.compactMap { $0.name }.count == 3 )
		} catch {
			XCTFail( "Parsing Core Data test failed: \(error)" )
		}
	}

	/**
	Check that partial changes are not saved when the parsing fails.
	For example we don't delete our old elements if the decoding of the new elements fails.
	*/
	func testDecodableCoreDataSavingRollback() async {
		// Create test JSON data
		guard let jsonData = regularJSON.data( using: .utf8 ) else {
			return XCTFail( "Incorrect JSON data" )
		}
		
		// Create a Core Data updater with a main thread managed object context
		let coreDataUpdater = CoreDataUpdater<CoreDataTestModel>( context: CoreDataManager.shared.mainQueueManagedObjectContext )
		
		// Parse the test data
		async let objects = ManagedObjectDataTaskResponseDecoder(
			coreDataUpdater: coreDataUpdater,
			jsonDecoder: JSONDecoder())
			.decode(data: jsonData) as [SafeCoreDataDecodable<CoreDataTestModel>]
		
		do {
			// Assert that we got the correct number of objects
			let count = try await objects.count
			XCTAssert(count == 4)
		} catch {
			XCTFail( "Parsing Core Data test failed: \(error)" )
		}

		// Now let's try a failing parsing.
		guard let failingJSONData = failingElementJSON.data( using: .utf8 ) else {
			return XCTFail( "Incorrect JSON data" )
		}
		
		let newCoreDataUpdater = CoreDataUpdater<CoreDataTestModel>( context: CoreDataManager.shared.mainQueueManagedObjectContext )

		do {
			// This time we don't ignore invalid elements
			_ = try await ManagedObjectDataTaskResponseDecoder(
					coreDataUpdater: newCoreDataUpdater,
					jsonDecoder: JSONDecoder())
				.decode(data: failingJSONData) as [UnsafeCoreDataDecodable<CoreDataTestModel>]

			XCTFail( "Got success when parsing failure was expected" )
		} catch {
			do {
				// The parsing failed as expected, verify that the objects we had did not get deleted
				let objects =  try CoreDataManager.shared.mainQueueManagedObjectContext.fetch( CoreDataTestModel.fetchRequest() ) as! [CoreDataTestModel]	// Fetch request must match results -GKD
				XCTAssert( objects.count == 4)
				XCTAssert( objects.compactMap { $0.id }.count == 4 )
				XCTAssert( objects.compactMap { $0.name }.count == 4 )
			} catch {
				XCTFail( "Core Data fetch failed: \(error)" )
			}
		}
	}

}

/**
An array with test model objects formatted as JSON
*/
let regularJSON = """
[{
	"id": 508544,
	"name": "VOC Gift Title"
},{
	"id": 508569,
	"name": "VMS Gift Title"
},{
	"id": 508594,
	"name": "VOS Gift Title"
}, {
	"id": 508619,
	"name": "VAC Gift Title"
}]
"""

/**
An array with an invalid element/
*/
let failingElementJSON = """
[{
	"id": 508544
},{
	"id": 508569,
	"name": "VMS Gift Title"
},{
	"id": 508594,
	"name": "VOS Gift Title"
}, {
	"id": 508619,
	"name": "VAC Gift Title"
}]
"""
