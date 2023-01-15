//
//  Database.swift
//	CoreDataManager
//
//  Created by Coruț Fabrizio on 18.06.2021.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataManager {
	
	/// Small representation of a `database storage file`. Provides convenience properties.
	public struct Database {
		
		static var `default`: Database {
			let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
			return Database(baseURL: url, name: "database", type: .sqlite)
		}
		
		static var inMemory: Database {
			let url = URL(fileURLWithPath: "/dev/null")
			return Database(baseURL: url, name: "database", type: .sqlite)
		}
		
		public enum `Type`: String {
			case sqlite
			case inMemory
		}

		/// Absolute path of a valid directory on disk where the storage should be saved.
		public let baseURL: URL

		/// How the storage file will be named on disk.
		public let name: String

		/// Defines the extension of the storage. Each type has its own properties.
		public let type: `Type`

		/// Relative path to where the storage file can be found.
		public let relativePath: String

		/// Absolute path to the `storage file`.
		public let absoluteURL: URL

		/// Absolute paths to the `Joural` files.
		// More about Journaling and where the paths are coming from: https://sqlite.org/wal.html
		public var journalFilesAbsoluteURLs: [URL] { ["-shm", "-wal"].map { baseURL.appendingPathComponent("\(absoluteURL)\($0)") } }

		/// Absolute paths to `all` the `Database` related files.
		public var allAbsoluteURLs: [URL] { [absoluteURL] + journalFilesAbsoluteURLs }

		/// - Parameters:
		///   - baseURL: Absolute path of a valid directory on disk where the storage should be saved.
		///   - name: How the storage file will be named on disk.
		///   - type: Defines the extension of the storage. Each type has its own properties.
		public init( baseURL: URL, name: String, type: `Type` ) {
			self.baseURL = baseURL
			self.name = name
			self.type = type
			self.relativePath = "\(name).\(type.rawValue)"
			self.absoluteURL = baseURL.appendingPathComponent( relativePath )
		}
	}
	
}
