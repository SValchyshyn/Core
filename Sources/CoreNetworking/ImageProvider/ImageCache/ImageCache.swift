//
//  ImageCache.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 13.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import ImageIO
import Core
import Foundation

/// Local cache for image data
public struct ImageCache {
	
	public typealias Identifier = String
	
	private enum ImageCacheError: Error {
		case invalidURLRequest
	}
	
	public static let shared = ImageCache(fileCache: .shared)
	
	private let fileCache: FileCache
	
	init(fileCache: FileCache) {
		self.fileCache = fileCache
	}
	
	// MARK: Read
	
	/// Returns image source by url request. Identifier is used to store different image data for the same url request.
	public func imageSource(for urlRequest: URLRequest, with identifier: Identifier? = nil) -> CGImageSource? {
		localURL(for: urlRequest, with: identifier).flatMap(CGImageSource.make)
	}
	
	/// Returns image local URL by url request
	public func localURL(for urlRequest: URLRequest, with identifier: Identifier? = nil) -> URL? {
		guard let remoteURL = urlRequest.url else { return nil }
		return fileCache.fileURL(with: .imageSource(for: remoteURL, with: identifier))
	}
	
	// MARK: Write
	
	/// Writes image data for url request. Identifier is used to store different image data for the same url request.
	public func storeImage(with data: Data, for urlRequest: URLRequest, with identifier: Identifier? = nil) throws {
		guard let remoteURL = urlRequest.url else { throw ImageCacheError.invalidURLRequest }
		try fileCache.storeData(data, to: .imageSource(for: remoteURL, with: identifier))
	}
	
	// MARK: Remove
	
	public func removeAll(olderThan timeInterval: TimeInterval? = nil) {
		timeInterval.map(fileCache.removeAll) ?? fileCache.removeAll()
	}
	
}

private extension FileCache.RelativePath {
	
	static func imageSource(for remoteURL: URL, with identifier: ImageCache.Identifier?) -> Self {
		make(folderName: remoteURL.absoluteString.urlEncoded, fileName: identifier ?? "original")
	}
	
}

private extension String {
	
	var urlEncoded: String {
		addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) // Try url encode
			?? Data(utf8).base64EncodedString() // otherwise try base64 encode
	}
	
}
