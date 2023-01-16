//
//  InAppActionExecutor.swift
//  CoopUI
//
//  Created by Olexandr Belozierov on 13.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

/// Abstract class to perform in-app actions. Should be overriden to implement custom logic.
open class InAppActionExecutor {
	
	public typealias Completion = (Error?) -> Void
	
	public init() {}
	
	/// Performs `InAppAction`. Should be overriden. Default implementation do nothing.
	open func execute(completion: Completion? = nil) {
		completion?(nil)
	}
	
}

public extension InAppActionExecutor {
	
	/// It is just empty block. For convenient marking `InAppActionExecutor` search as found.
	static var finish: InAppActionExecutor { InAppActionExecutor() }
	
}
