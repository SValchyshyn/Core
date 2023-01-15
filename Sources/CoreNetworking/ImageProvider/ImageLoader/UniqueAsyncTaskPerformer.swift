//
//  UniqueAsyncTaskPerformer.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 12.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

/// Manager for performing task by key.
/// It will not start new task if there is already task with such key and will wait for it result.
actor UniqueAsyncTaskPerformer<Key: Hashable, Success> {
	
	typealias Operation = () async throws -> Success
	private typealias AsyncTask = Task<Void, Error>
	private typealias Continuation = CheckedContinuation<Success, Error>
	
	private struct InternalTask {
		let task: AsyncTask
		var continuations: [UUID: Continuation]
	}
	
	private var internalTasks = [Key: InternalTask]()
	
	nonisolated func performTask(for key: Key, operation: @escaping Operation) async throws -> Success {
		try Task.checkCancellation()
		let identifier = UUID()
		
		return try await withTaskCancellationHandler {
			try await withCheckedThrowingContinuation { continuation in
				Task { await performTask(for: key, identifier: identifier, continuation: continuation, operation: operation) }
			}
		} onCancel: {
			Task { await cancelTask(for: key, identifier: identifier) }
		}
	}
	
	private func performTask(for key: Key, identifier: UUID, continuation: Continuation, operation: @escaping Operation) {
		if var internalTask = internalTasks[key] {
			internalTask.continuations[identifier] = continuation
			internalTasks[key] = internalTask
		} else {
			let task = AsyncTask.detached { [self] in
				do {
					try Task.checkCancellation()
					let value = try await operation()
					
					try Task.checkCancellation()
					await completeTask(for: key, with: .success(value))
				} catch {
					await completeTask(for: key, with: .failure(error))
				}
			}
			internalTasks[key] = InternalTask(task: task, continuations: [identifier: continuation])
		}
	}
	
	private func completeTask(for key: Key, with result: Result<Success, Error>) {
		internalTasks.removeValue(forKey: key)?.continuations.values.forEach { $0.resume(with: result) }
	}
	
	private func cancelTask(for key: Key, identifier: UUID) {
		guard var internalTask = internalTasks[key] else { return }
		
		internalTask.continuations.removeValue(forKey: identifier)?.resume(throwing: CancellationError())
		internalTasks[key] = internalTask
		
		if internalTask.continuations.isEmpty { cancelTask(for: key) }
	}
	
	func cancelTask(for key: Key) {
		guard let internalTask = internalTasks.removeValue(forKey: key) else { return }
		
		internalTask.task.cancel()
		internalTask.continuations.values.forEach { $0.resume(throwing: CancellationError()) }
	}
	
}
