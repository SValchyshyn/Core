//
//  FileCache.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 12.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

struct FileCache {
	
	/// The relative path of the base URL.
	struct RelativePath {
		
		/// Creates path with file name in folder.
		static func make(folderName: String, fileName: String) -> Self {
			Self(path: "\(folderName)/\(fileName)")
		}
		
		/// The relative path.
		fileprivate let path: String
		
		init(path: String) {
			self.path = path
		}
		
	}
	
	static let shared = cacheFolder(name: "Shared")
	
	static func cacheFolder(name: String) -> Self {
		let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
		return Self(baseURL: cacheURL.appendingPathComponent(name))
	}
	
	/// Base directory URL for cache.
	private let baseURL: URL
	
	init(baseURL: URL) {
		self.baseURL = baseURL
	}
	
	// MARK: Helpers
	
	private var fileManager: FileManager { .default }
	
	/// Creates local URL with relative path.
	private func localURL(with path: RelativePath) -> URL {
		baseURL.appendingPathComponent(path.path)
	}
	
	// MARK: Read
	
	/// Returns file URL by relative path
	func fileURL(with path: RelativePath) -> URL? {
		let fileURL = localURL(with: path)
		
		// Check if file exist and if it is file
		var isDirectory: ObjCBool = false
		guard fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory),
			  !isDirectory.boolValue else { return nil }
		
		return fileURL
	}
	
	// MARK: Write
	
	/// Saves data into cache by relative path.
	func storeData(_ data: Data, to path: RelativePath) throws {
		let fileURL = localURL(with: path)
		
		// Create directories if needed
		try? fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
		
		try data.write(to: fileURL)
	}
	
	// MARK: Remove
	
	/// Removes file/directory by relative path.
	func removeItem(with path: RelativePath) {
		let fileURL = localURL(with: path)
		try? fileManager.removeItem(at: fileURL)
	}
	
	/// Removes files that have modification time older than time interval.
	func removeAll(olderThan timeInterval: TimeInterval) {
		let threshold = Date(timeIntervalSinceNow: -timeInterval.magnitude)
		let propertyKeys = [URLResourceKey.isRegularFileKey, .contentModificationDateKey]
		try? fileManager.enumerator(at: baseURL, includingPropertiesForKeys: propertyKeys)?.forEach {
			guard let fileURL = $0 as? URL else { return }
			let fileAttributes = try fileURL.resourceValues(forKeys: Set(propertyKeys))
			
			guard let modificationDate = fileAttributes.contentModificationDate, modificationDate < threshold, fileAttributes.isRegularFile == true else { return }
			
			try fileManager.removeItem(at: fileURL)
		}
	}
	
	/// Reset cache.
	func removeAll() {
		try? fileManager.removeItem(at: baseURL)
	}
	
}
