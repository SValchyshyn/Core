//
//  InAppActionable.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 15.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

/// Protocol for performing extended in app actions
public protocol InAppActionable2 {
	
	func inAppActionExecutor(for action: InAppAction2) -> InAppActionExecutor?
	
}

extension InAppActionable2 {
	
	public func execute(inAppAction: InAppAction2, completion: ((Error?) -> Void)?) {
		inAppActionExecutor(for: inAppAction)?.execute(completion: completion)
			?? completion?(InAppActionableError.inAppActionExecutorNotFound)
	}
	
	public func execute(inAppAction: InAppAction2) {
		execute(inAppAction: inAppAction, completion: nil)
	}
	
}

private enum InAppActionableError: Error {
	case inAppActionExecutorNotFound
}
