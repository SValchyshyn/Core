//
//  ManagedObjectDataTaskResponseDecoder.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 18.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import CoreData
import Core
import CoreDataManager

/// Decodes response data into managed object value.
struct ManagedObjectDataTaskResponseDecoder<T: Decodable, U: NSManagedObject & UpdatePolicyDelegate>: DataTaskResponseDecoder {
	
	let coreDataUpdater: CoreDataUpdater<U>
	let jsonDecoder: JSONDecoder
	
	func decode(data: Data) async throws -> T {
		try await coreDataUpdater.updateEntities(data: data, decoder: jsonDecoder)
	}
	
}
