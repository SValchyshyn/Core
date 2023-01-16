//
//  StartupManager.swift
//  CoopCore
//
//  Created by Jens Willy Johannsen on 11/12/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

import UIKit

/**
Use the StartupManager to perform operations when starting the app.
The manager supports both sequential operations (like asking for Location permissions, then Push Notification permissions) and background operations (downloading JSON etc.).

Some operations are already implemented (look in the StartupManager folder) and some can be implemented using simple NSBlockOperations.
*/
open class StartupManager: NSObject {

	// MARK: Public
	/**
	Number of concurrent operations on the startup manager's operation queue.
	Default is 1.
	*/
	open var maxConcurrentOperations: Int = 1 {
		didSet {
			_opqueue.maxConcurrentOperationCount = maxConcurrentOperations
		}
	}

	/**
	Whether or not the startup manager's queue is suspended. Default is false.
	*/
	open var suspended: Bool {
		get {
			return _opqueue.isSuspended
		}
		set {
			_opqueue.isSuspended = newValue
		}
	}

	// MARK: Private
	private var _opqueue: OperationQueue = {
		let opqueue = OperationQueue()
		opqueue.maxConcurrentOperationCount = 1 // Serial queue by default
		return opqueue
	}()

	/**
	Shared instance of the startup manager. Use this singleton for all operations.
	*/
	public static let shared = StartupManager()

	// MARK: Functions

	open func addOperation(_ operation: Operation) {
		_opqueue.addOperation(operation)
	}
}
