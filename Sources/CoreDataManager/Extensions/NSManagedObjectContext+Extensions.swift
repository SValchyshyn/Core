//
//  NSManagedObjectContext+Extensions.swift
//  CoreDataManager
//
//  Created by Olexandr Belozierov on 05.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
	
	private enum ClearCacheError: Error {
		case resultParseError
	}
	
	func clearCachedEntities(with entityNames: [String]) throws {
		let objectIDs = try entityNames.flatMap { entityName -> [NSManagedObjectID] in
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
			
			let batchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
			batchRequest.resultType = .resultTypeObjectIDs
			
			guard let result = try execute(batchRequest) as? NSBatchDeleteResult,
				  let objectIDs = result.result as? [NSManagedObjectID] else {
				throw ClearCacheError.resultParseError
			}
			
			return objectIDs
		}
		
		mergeChanges(changes: [NSDeletedObjectsKey: objectIDs])
	}
	
	private func mergeChanges(changes: [AnyHashable: Any]) {
		NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
	}
	
	@discardableResult
	public func awaitPerform<T>(_ block: @escaping () throws -> T) async throws -> T {
		try await withCheckedThrowingContinuation { continuation in
			perform {
				continuation.resume(with: Result(catching: block))
			}
		}
	}
	
	@discardableResult
	public func awaitPerform<T>(_ block: @escaping () -> T) async -> T {
		await withCheckedContinuation { continuation in
			perform {
				continuation.resume(returning: block())
			}
		}
	}
	
}
