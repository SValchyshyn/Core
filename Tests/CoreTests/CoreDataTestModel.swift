//
//  TestModel.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 21/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import CoreData
import CoreDataManager

@testable import Core

/**
NSManagedObject class used when testing CoreData related functionality. Only added to the unit test target.
*/
class CoreDataTestModel: NSManagedObject, DecoderConfigurable, UpdatePolicyDelegate {
	enum CodingKeys: String, CodingKey {
		case id
		case name
	}

	var id: Int?
	var name: String?

	public func configure(from decoder: Decoder) throws {
		// Configure the object
		let container = try decoder.container( keyedBy: CodingKeys.self )
		self.id = try container.decode( Int.self, forKey: .id ) as Int
		self.name = try container.decode( String.self, forKey: .name ) as String
	}

	public static func deleteFetchRequests() -> [NSFetchRequest<NSFetchRequestResult>] {
		return [CoreDataTestModel.fetchRequest()]
	}
}
