//
//  UniqueTaskExecutor.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 02.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

actor UniqueTaskExecutor<Key: Hashable, Value> {
	
	private var tasks = [Key: Task<Value, Error>]()
	
	func performTask(for key: Key, operation: @escaping () async throws -> Value) async throws -> Value {
		// Check if there is updating task already and wait for it result to avoid multiple requests
		if let task = tasks[key] { return try await task.value }
		let task = Task.detached { try await operation() }
		
		// Store task while executing
		tasks[key] = task
		defer { tasks[key] = nil }
		
		return try await task.value
	}
	
	func cancelTasks() {
		tasks.values.forEach { $0.cancel() }
		tasks.removeAll()
	}
	
}
