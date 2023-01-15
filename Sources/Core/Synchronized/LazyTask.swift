//
//  LazyTask.swift
//  Core
//
//  Created by Oleksandr Belozierov on 09.12.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

/// Wrapper for async `Task` that creates and runs it on demand.
public struct LazyTask<Success, Failure: Error>: Sendable {
	
	/// Thread-safe lazy async task provider.
	private actor LazyTaskProvider {
		
		fileprivate typealias TaskFactory = () -> Task<Success, Failure>
		
		/// Factory for new async task.
		private let taskFactory: TaskFactory
		
		/// Async task cache.
		private var existTask: Task<Success, Failure>?
		
		fileprivate init(taskFactory: @escaping TaskFactory) {
			self.taskFactory = taskFactory
		}
		
		fileprivate var task: Task<Success, Failure> {
			if let existTask { return existTask }
			
			let task = taskFactory()
			existTask = task
			return task
		}
		
	}
	
	/// Thread-safe lazy async task provider.
	private let lazyTaskProvider: LazyTaskProvider
	
}

extension LazyTask where Failure == Error {
	
	public init(priority: TaskPriority? = nil, operation: @escaping () async throws -> Success) {
		lazyTaskProvider = LazyTaskProvider {
			Task(priority: priority) {
				try await operation()
			}
		}
	}
	
	/// The result from a throwing task, after it completes.
	public var value: Success {
		get async throws {
			try await lazyTaskProvider.task.value
		}
	}
	
}

extension LazyTask where Failure == Never {
	
	public init(priority: TaskPriority? = nil, operation: @escaping () async -> Success) {
		lazyTaskProvider = LazyTaskProvider {
			Task(priority: priority) {
				await operation()
			}
		}
	}
	
	/// The result from a nonthrowing task, after it completes.
	public var value: Success {
		get async {
			await lazyTaskProvider.task.value
		}
	}
	
}
