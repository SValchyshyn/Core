//
//  SafeCoreDataDecodable.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 23/05/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import CoreData

/// Defines a way for an object to be configured using a `Decoder`.
public protocol DecoderConfigurable {
	/**
	Should configure the object by parsing the data from the `Decoder`.

	- parameter decoder:		Contains the fields information.
	*/
	func configure( from decoder: Decoder ) throws
}

/// Typealias of `NSManagedObject` and `DecoderConfigurable`.
public typealias DecodableCoreDataObject = NSManagedObject & DecoderConfigurable

/// Used to safely decode a `CoreData` object.
/// Since `CoreData` objects have a required `init`, we first have to insert the object in the context and then parse the fields.
/// If somehow the parsing fails and we have a fauly JSON, we must throw and error. In such situations, the inserted empty object must be cleaned up
/// from `CoreData`. This is what this wrapper is taking care of, cleaning the object if the parsing somehow fails.
public struct SafeCoreDataDecodable<T: DecodableCoreDataObject>: Decodable {
	/// The decoded object.
	public let object: T?

	// MARK: - Decoder

	public init( from decoder: Decoder ) throws {
		guard let context = decoder.userInfo[ CodingUserInfoKey.managedObjectContext ] as? NSManagedObjectContext else {
			fatalError( "Context not set for Decodable Core Data object" )
		}

		// Create the CoreData object.
		let temporaryObject: T = .init( context: context )
		do {
			// Try to configure it using Decodable.
			try temporaryObject.configure( from: decoder )

			// Parsing did not fail, assign the object.
			self.object = temporaryObject
		} catch {
			// The parsing failed, delete the object.
			context.delete( temporaryObject )
			self.object = nil
		}
	}
}

/// Used to unsafely decode a `CoreData` object, meaning that if an object is not decoded properly, an exception is thrown upwards in the call chain.
/// Since `CoreData` objects have a required `init`, we first have to insert the object in the context and then parse the fields.
/// If somehow the parsing fails and we have a fauly JSON, we must throw and error. In such situations, the inserted empty object must be cleaned up
/// from `CoreData`. This is what this wrapper is taking care of, cleaning the object if the parsing somehow fails.
public struct UnsafeCoreDataDecodable<T: DecodableCoreDataObject>: Decodable {
	/// The decoded object.
	public let object: T?

	// MARK: - Decoder

	public init( from decoder: Decoder ) throws {
		guard let context = decoder.userInfo[ CodingUserInfoKey.managedObjectContext ] as? NSManagedObjectContext else {
			fatalError( "Context not set for Decodable Core Data object" )
		}

		// Create the CoreData object.
		let temporaryObject: T = .init( context: context )

		do {
			// Try to configure it using Decodable.
			try temporaryObject.configure( from: decoder )

			// Parsing did not fail, assign the object.
			self.object = temporaryObject
		} catch let error {
			// The parsing failed, delete the object.
			context.delete( temporaryObject )
			throw error
		}
	}
}
