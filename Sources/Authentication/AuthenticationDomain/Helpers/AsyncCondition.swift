//
//  AsyncCondition.swift
//  AuthenticationDomain
//
//  Created by Olexandr Belozierov on 01.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

/// Condition variable implementation using async/await approach.
actor AsyncCondition {
	
	private typealias Continuation = CheckedContinuation<Void, Never>
	
	private var continuations = [Continuation]()
	
	private func append(_ continuation: Continuation) {
		continuations.append(continuation)
	}
	
	private func removeAll() -> [Continuation] {
		defer { continuations.removeAll() }
		return continuations
	}
	
	// MARK: Wait
	
	func wait() async {
		await withCheckedContinuation(append)
	}
	
	// MARK: Broadcast
	
	@Sendable nonisolated func broadcast() async {
		await removeAll().forEach { $0.resume() }
	}
	
	nonisolated func startBroadcastTask() {
		Task(operation: broadcast)
	}
	
}
