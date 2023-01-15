//
//  NSPersistentContainer+Extensions.swift
//  CoreDataManager
//
//  Created by Olexandr Belozierov on 05.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
	
	convenience init(name: String, model: NSManagedObjectModel?) {
		if let model = model {
			self.init(name: name, managedObjectModel: model)
		} else {
			self.init(name: name)
		}
	}
	
}
