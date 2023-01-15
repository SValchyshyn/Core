//
//  RemoteLogCoreDataRepository.swift
//  RemoteLog
//
//  Created by Adrian Ilie on 06.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Core
import CoreData
import CoreDataManager

public final class RemoteLogCoreDataRepository: RemoteLogRepositoryProvider {
	private let coreDataManager: CoreDataManager
	
	init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
		self.coreDataManager = coreDataManager
		self.backgroundObjectContext = coreDataManager.newPrivateManagedObjectContext()
	}
	
	// MARK: - CoreData
	
	private var backgroundObjectContext: NSManagedObjectContext
	
	/// Identifiers of log entries currently in transfer
	private var transferring: Set<NSManagedObjectID> = []
	
	// MARK: - RemoteLogRepositoryProvider
	
	public var snApplication: String = ""
	
	public func scheduleForTransfer(_ entry: RemoteLogEntry) async throws {
		try await backgroundObjectContext.awaitPerform {
			// Verify if `RemoteLogCDEntity` model has been loaded into CoreData.
			// Since `RemoteLogging` is used even in app start behaviour, there might be situations where it is used before CoreData had a change to initialize it's model.
			// This is done to prevent NSExceptions being thrown, which can't be catched in Swift.
			guard self.coreDataManager.managedObjectModel.entities.contains(RemoteLogCDEntity.entity()) else {
				throw RemoteLogRepositoryError.storageFail
			}
			
			let cdEntry = RemoteLogCDEntity(context: self.backgroundObjectContext)
			cdEntry.fromModel(entry)

			do {
				try self.backgroundObjectContext.save()
			} catch {
				throw RemoteLogRepositoryError.storageFail
			}
		}
	}
	
	public func fetchForTransfer() async throws -> (EntryIdentifier, RemoteLogEntry)? {
		try await backgroundObjectContext.awaitPerform {
			// Fetch the oldest log entry from core data not currently in transfer.
			// Logs with the highest retry count will be sorted last.
			let request = NSFetchRequest<RemoteLogCDEntity>(entityName: RemoteLogCDEntity.entity().name!)
			request.sortDescriptors = [NSSortDescriptor(key: #keyPath(RemoteLogCDEntity.retryCount), ascending: true),
									   NSSortDescriptor(key: #keyPath(RemoteLogCDEntity.timestamp), ascending: true)]
			request.predicate = NSPredicate(format: "NOT (self IN %@)", self.transferring)
			request.fetchLimit = 1
			
			guard let result = try? self.backgroundObjectContext.fetch(request) else {
				throw RemoteLogRepositoryError.storageFail
			}
			guard let cdEntry = result.first else {
				return nil // NOT an error, all log entries have been processed
			}

			// Mark log entry as transferring
			self.transferring.insert(cdEntry.objectID)
			do {
				try self.backgroundObjectContext.save()
			} catch {
				throw RemoteLogRepositoryError.storageFail
			}
			
			// Return model
			var entry = cdEntry.toModel()
			entry.snApplication = self.snApplication
			return (
				cdEntry.objectID.uriRepresentation().absoluteString,
				entry
			)
		}
	}
	
	public func markAsTransffered(_ identifier: EntryIdentifier) async throws {
		try await backgroundObjectContext.awaitPerform {
			guard let uriIdentifier = URL(string: identifier),
				  let objectId = self.backgroundObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uriIdentifier)
			else {
				throw RemoteLogRepositoryError.storageFail
			}
			
			guard let cdEntry = self.backgroundObjectContext.object(with: objectId) as? RemoteLogCDEntity else {
				throw RemoteLogRepositoryError.storageFail
			}
			
			self.backgroundObjectContext.delete(cdEntry)
			self.transferring.remove(objectId)
			
			do {
				guard self.backgroundObjectContext.hasChanges else { return }
				try self.backgroundObjectContext.save()
			} catch {
				throw RemoteLogRepositoryError.storageFail
			}
		}
	}
	
	public func markAsNotTransffered(_ identifier: EntryIdentifier) async throws {
		try await backgroundObjectContext.awaitPerform {
			guard let uriIdentifier = URL(string: identifier),
				  let objectId = self.backgroundObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uriIdentifier)
			else {
				throw RemoteLogRepositoryError.storageFail
			}
			
			guard let cdEntry = self.backgroundObjectContext.object(with: objectId) as? RemoteLogCDEntity else {
				throw RemoteLogRepositoryError.storageFail
			}

			// Increment the retry count in overflow-safe way.
			cdEntry.retryCount += cdEntry.retryCount == .max ? 0 : 1
			
			self.transferring.remove(objectId)
			
			do {
				guard self.backgroundObjectContext.hasChanges else { return }
				try self.backgroundObjectContext.save()
			} catch {
				throw RemoteLogRepositoryError.storageFail
			}
		}
	}
}
