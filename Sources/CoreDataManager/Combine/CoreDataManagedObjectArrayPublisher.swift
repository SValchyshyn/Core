//
//  CoreDataManagedObjectArrayPublisher.swift
//  CoreDataManager
//
//  Created by Adrian Ilie on 20.07.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Combine
import CoreData

public class CoreDataManagedObjectArrayPublisher<ManagedObject: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
	public enum PublisherError: Error {
		case coreDataFailure(Error?)
	}
	
	public let fetchResultsController: NSFetchedResultsController<ManagedObject>
	
	private let content = CurrentValueSubject<[ManagedObject], PublisherError>([])
	
	public init(
		fetchRequest: NSFetchRequest<ManagedObject>,
		managedObjectContext: NSManagedObjectContext
	) {
		fetchResultsController = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: managedObjectContext,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		
		super.init()
		
		fetchResultsController.delegate = self
		
		do {
			try fetchResultsController.performFetch()
			content.value = fetchResultsController.fetchedObjects ?? []
		} catch {
			content.send(completion: .failure(.coreDataFailure(error)))
		}
	}
	
	public var publisher: AnyPublisher<[ManagedObject], PublisherError> {
		content.eraseToAnyPublisher()
	}
	
	// MARK: - NSFetchedResultsControllerDelegate
	
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		content.value = fetchResultsController.fetchedObjects ?? []
	}
}
