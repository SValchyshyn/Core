//
//  InAppActionGroupExecutor.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 31.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

/// `InAppActionExecutor` subclass for group list of other `InAppActionExecutor`s
public class InAppActionGroupExecutor: InAppActionExecutor {
	
	/// Sub executors.
	public let executors: [InAppActionExecutor]
	
	public init(executors: [InAppActionExecutor]) {
		// Flat map executors to avoid of using multi layers of `InAppActionGroupExecutor` in sub executors
		self.executors = executors.flatMap { executor -> [InAppActionExecutor] in
			if let group = executor as? InAppActionGroupExecutor {
				return group.executors
			}
			return [executor]
		}
	}
	
	public override func execute(completion: Completion? = nil) {
		executors.execute(completion: completion)
	}
	
}

fileprivate extension Sequence where Element: InAppActionExecutor {
	
	/// Executes sequence of `InAppActionExecutor`s
	func execute(completion: InAppActionExecutor.Completion? = nil) {
		var iterator = makeIterator()
		
		func performNext() {
			guard let next = iterator.next() else {
				completion?(nil)
				return
			}
			
			next.execute { error in
				guard let error = error else {
					return performNext() // Perform next executor
				}
				
				completion?(error) // Stop executing with error
			}
		}
		
		performNext() // Start executing
	}
	
}
