//
//  SynchronizedArray.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 07/01/2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

/**
Array which allows concurrent reads but synchronizes the write operations
*/
public class SynchronizedArray<T> {
	private var array: [T] = []
	private let accessQueue = DispatchQueue(label: "SynchronizedArrayAccess", attributes: .concurrent)

	// Explicitly public initializer
	public init() {}

	/**
	Adds an element to the end of the collection.
	*/
	public func append(_ newElement: T) {
		// We use the `.barrier` flag to block other operations while we edit the array
		self.accessQueue.async(flags: .barrier) {
			self.array.append(newElement)
		}
	}

	/**
	Removes the element at the specified position.
	*/
	public func removeAtIndex(index: Int) {
		// We use the `.barrier` flag to block other operations while we edit the array
		self.accessQueue.async(flags: .barrier) {
			self.array.remove(at: index)
		}
	}

	/// The number of elements in the array
	public var count: Int {
		var count = 0

		self.accessQueue.sync {
			count = self.array.count
		}

		return count
	}

	/// The first element in the array
	public func first() -> T? {
		var element: T?

		self.accessQueue.sync {
			element = self.array.first
		}

		return element
	}

	public subscript(index: Int) -> T {
		get {
			var element: T!
			self.accessQueue.sync {
				element = self.array[index]
			}

			return element
		}
		
		set {
			// We use the `.barrier` flag to block other operations while we edit the array
			self.accessQueue.async(flags: .barrier) {
				self.array[index] = newValue
			}
		}
	}

	/// Return the raw array represanation
	public var rawArray: [T] {
		var array: [T] = []

		self.accessQueue.sync {
			array = self.array
		}

		return array
	}
}
