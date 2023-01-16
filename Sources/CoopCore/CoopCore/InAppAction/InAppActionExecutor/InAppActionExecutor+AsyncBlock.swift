//
//  InAppActionExecutor+AsyncBlock.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 31.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

/// `InAppActionExecutor` subclass for async block.
private class InAppActionAsyncBlockExecutor: InAppActionExecutor {
	
	typealias AsyncBlock = (@escaping Completion) -> Void
	
	private let asyncBlock: AsyncBlock
	
	init(asyncBlock: @escaping AsyncBlock) {
		self.asyncBlock = asyncBlock
	}
	
	override func execute(completion: Completion? = nil) {
		asyncBlock { error in completion?(error) }
	}
	
}

public extension InAppActionExecutor {
	
	/// Creates new executor with async block.
	static func asyncBlock(_ block: @escaping (@escaping Completion) -> Void) -> InAppActionExecutor {
		InAppActionAsyncBlockExecutor(asyncBlock: block)
	}
	
	/// Creates new executor with sync block.
	static func block(_ block: @escaping () throws -> Void) -> InAppActionExecutor {
		asyncBlock { completion in
			do {
				try block()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	/// Creates new executor with error.
	static func `throw`(error: Error) -> InAppActionExecutor {
		asyncBlock { completion in completion(error) }
	}
	
}
