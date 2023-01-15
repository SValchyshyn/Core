//
//  CoreDataUpdater.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 17/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import CoreData
import Core

/**
A class that updates entities in Core Data based on the provided parameters.
*/
public class CoreDataUpdater<T: NSManagedObject & UpdatePolicyDelegate> {
	/// The context to perform the updates on.
	let context: NSManagedObjectContext

	/// The update policy to use when updating Core Data entities.
	let updatePolicy: UpdatePolicy

	/// Custom delete fetch requests.
	let deleteFetchRequests: [NSFetchRequest<NSFetchRequestResult>]?

	/**
	Initializes a `CoreDataRecordUpdater` instance with the passed parameters.

	- parameters:
		- context: The context to perform the updates on.
		- updatePolicy: The update policy to apply when performing the updates.  Defaults to `.deleteAllAndInsert`
	*/
	public init( context: NSManagedObjectContext, updatePolicy: UpdatePolicy = .deleteAllAndInsert, deleteFetchRequests: [NSFetchRequest<NSFetchRequestResult>]? = nil ) {
		self.context = context
		self.updatePolicy = updatePolicy
		self.deleteFetchRequests = deleteFetchRequests
	}

	/**
	Parse the data to the decodable type. The objects are stored in CoreData and the previous values are updated according to the set update policy.
	*/
	public func updateEntities<U: Decodable>( data: Data, decoder: JSONDecoder ) -> Result<U, Error> {
		var result: Result<U, Error> = .failure( APIError.unableToConvertData )
		context.performAndWait {
			result = Result {
				try _updateEntities(data: data, decoder: decoder)
			}
		}
		return result
	}
	
	/**
	Parse the data to the decodable type. The objects are stored in CoreData and the previous values are updated according to the set update policy.
	*/
	public func updateEntities<U: Decodable>( data: Data, decoder: JSONDecoder ) async throws -> U {
		try await withCheckedThrowingContinuation { continuation in
			context.perform {
				let result = Result<U, Error> {
					try self._updateEntities(data: data, decoder: decoder)
				}
				
				continuation.resume(with: result)
			}
		}
	}
	
	private func _updateEntities<U: Decodable>(data: Data, decoder: JSONDecoder) throws -> U {
		do {
			// Parse and update the objects depending on the update policy
			switch updatePolicy {
			case .deleteAllAndInsert:
				// Delete old objects
				try deleteAllEntities()

				// Set the managed object context on the decoder, so we can use it when parsing the models
				decoder.userInfo[ .managedObjectContext ] = context

				// Decode the objects.
				let entities: U = try decoder.decode( U.self, from: data )

				// Save the changes only if we have any.
				if context.hasChanges {
					try context.save()
				}
				
				return entities
			}
		} catch {
			// Something went wrong. Discard the changes, we don't want partial updates.
			context.rollback()

			// Throw an error
			throw error
		}
	}

	/**
	Delete all objects of the current NSManagedObject type from CoreData.
	Does **not** call `save()` on the managed object context.
	*/
	private func deleteAllEntities() throws {
		// Yes: Delete existing entities from core data
		let deleteRequests = deleteFetchRequests ?? T.deleteFetchRequests()
		try deleteRequests.forEach { fetchRequest in
			try context.fetch( fetchRequest ).lazy
				// Make sure we're only "fetching" NSManagedObjects.
				.compactMap { $0 as? NSManagedObject }
				// Delete the object from the context.
				.forEach { context.delete( $0 ) }
		}
	}
}

/**
An enumeration defining the different update policies to select from, when performing updates to a persistent medium.
*/
public enum UpdatePolicy {
	/// Deletes any existing records of persisted objects and persists the new objects.
	case deleteAllAndInsert
}

/// Provides the neccessary information for the `UpdatePolicy`.
public protocol UpdatePolicyDelegate: AnyObject {
	/// Fetch requests that will be used to remove the objects that
	static func deleteFetchRequests() -> [NSFetchRequest<NSFetchRequestResult>]
}

public extension CodingUserInfoKey {
	static let managedObjectContext = CodingUserInfoKey( rawValue: "managedObjectContext" )! // Explicit unwrap, would have failed the first time -GKD.
}
