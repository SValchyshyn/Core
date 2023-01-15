//
//  CoreDataManager.swift
//  CoreDataManager
//
//  Created by Niels Nørskov on 11/12/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

import CoreData

public class CoreDataManager {
	
	public static let shared = CoreDataManager(database: .default)
	
	/// `Storage file` representation.
	public let database: Database
	
	/// The NSURLIsExcludedFromBackupKey is set when adding the persistent store so be sure to set this property to the correct value _before_ instantiating the Core Data stack.
	public let excludeFromICloudBackup: Bool
	
	public init(database: Database, excludeFromICloudBackup: Bool = true) {
		self.database = database
		self.excludeFromICloudBackup = excludeFromICloudBackup
	}
	
	// MARK: NSManagedObjectModel
	
	/// Register the bundle to load Core Data models from. This method should be used in a modularized project.
	/// This will create a merged `NSManagedObjectModel`.
	///
	/// Instantiate the bundles using the `Bundle(identifier:)` initializer on `Bundle` with the bundle identifier of the framework/module.
	/// Remember to include `Bundle.main`, if the app also provides a model in the main bundle.
	///
	/// - Important: Don't use `Bundle.allBundles` if the application contains a versioned model, as this will crash the app.
	/// Provide the bundles for each module, that defines a Core Data model.
	///
	/// - Parameter bundles: The bundles to register and merge together to a single `NSManagedObjectModel`.
	public func registerBundles(_ bundles: [Bundle]) {
		// Don't register an empty array - instead stick to the current value
		guard !bundles.isEmpty else { return }
		
		// Create new container with merged model
		persistentContainer = makePersistentContainer(with: .mergedModel(from: bundles))
	}
	
	public var managedObjectModel: NSManagedObjectModel {
		persistentContainer.managedObjectModel
	}
	
	// MARK: NSPersistentContainer
	
	/// A container that encapsulates the Core Data stack.
	private lazy var persistentContainer = makePersistentContainer(with: nil)
	
	private func makePersistentContainer(with model: NSManagedObjectModel?) -> NSPersistentContainer {
		let container = NSPersistentContainer(name: database.name, model: model)

		// Configure description
		let description = NSPersistentStoreDescription(url: database.absoluteURL)
		description.shouldInferMappingModelAutomatically = true
		description.shouldMigrateStoreAutomatically = true

		// Load description
		container.persistentStoreDescriptions = [description]
		container.loadPersistentStores { description, error in
			if let error = error {
				print("Error adding persistent store: \(error)")
			}
			
			if self.excludeFromICloudBackup {
				do {
					try description.url?.updateExcludedFromBackupValue(true)
				} catch {
					print("Exception trying to exclude file from iCloud backup: \(error)")
				}
			}
		}
		
		// Auto merge changes from `newPrivateManagedObjectContext`s
		container.viewContext.automaticallyMergesChangesFromParent = true
		
		return container
	}
	
	// MARK: NSManagedObjectContext
	
	/// The main queue managed object context for the application (which is already bound to the persistent store coordinator for the application).
	public var mainQueueManagedObjectContext: NSManagedObjectContext {
		persistentContainer.viewContext
	}
	
	public func newPrivateManagedObjectContext() -> NSManagedObjectContext {
		persistentContainer.newBackgroundContext()
	}
	
	// MARK: Clear
	
	/// Clears all entries in data model synchronously.
	public func clearCachedEntities(with entityNames: [String]) {
		mainQueueManagedObjectContext.performAndWait {
			do {
				try mainQueueManagedObjectContext.clearCachedEntities(with: entityNames)
			} catch {
				print("CoreDataManager.clearAllEntities: \(error)")
			}
		}
	}
	
	/// Removes the `Database` that has been associated with the local storage. This method manually removes _all_ the files
	/// which have represented the local storage up until to this point. Because of this, this method **MUST** be called before accessing any other
	/// instance properties. All the instance properties that are related to `CoreData` are lazily initialized. Accessing one of them will trigger the `CoreData stakc`
	/// setup, hence if the removal of the files is required it's **imperative** that this method is called first.
	/// Calling this method **after** the persistent store have been loaded will yield undefined behaviour.
	///
	/// Useful in situations in which we want to avoid having to do a heavyeigth migration. Removing the `persistent stores` will basically
	/// provide a clean slate in which we can load fresh new models.
	/// - Throws: If something goes wrong with the `file deletion`.
	public func deleteDatabaseFiles() throws {
		try database.allAbsoluteURLs.forEach(FileManager.default.removeItem) // First clean-up.
	}
	
	/**
	 Delete all entities stored in CoreData.
	 */
	public func clear() {
		for entity in managedObjectModel.entities {
			guard let entityName = entity.name else { continue }
			
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
			let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

			_ = try? mainQueueManagedObjectContext.execute(deleteRequest)
		}
	}
}
