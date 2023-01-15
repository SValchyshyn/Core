//
//  OperationQueue+Extensions.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 17.06.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

extension OperationQueue {
	
	func awaitOperation<T>(_ block: @escaping () -> T) async -> T {
		await withCheckedContinuation { continuation in
			addOperation {
				continuation.resume(returning: block())
			}
		}
	}
	
	func awaitOperation<T>(_ block: @escaping () throws -> T) async throws -> T {
		try await withCheckedThrowingContinuation { continuation in
			addOperation {
				continuation.resume(with: Result(catching: block))
			}
		}
	}
	
}
