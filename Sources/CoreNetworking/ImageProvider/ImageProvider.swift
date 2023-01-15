//
//  ImageProvider.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 12.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit

public struct ImageProvider {
	
	/// Policy for storing filtered images
	public struct FilteredImageCachePolicy {
		
		/// Don't store filtered image, only original image
		public static let onlyOriginal = Self(cacheOriginal: true, cacheFilteredFormat: nil)
		
		/// Store only filtered image, but not original image
		public static func onlyFiltered(format: CGImage.DataFormat = .png) -> Self {
			Self(cacheOriginal: false, cacheFilteredFormat: format)
		}
		
		/// Store filtered and original images
		public static func both(filteredFormat: CGImage.DataFormat = .png) -> Self {
			Self(cacheOriginal: true, cacheFilteredFormat: filteredFormat)
		}
		
		fileprivate let cacheOriginal: Bool
		fileprivate let cacheFilteredFormat: CGImage.DataFormat?
		
	}
	
	private enum Constants {
		static let maxConcurrentOperationCount = 2
	}
	
	private enum ImageProviderError: Error {
		case incorrectURL, incorrectImageResponse
	}
	
	public static let shared = ImageProvider(imageCache: .shared, imageLoader: .shared)
	
	public let imageCache: ImageCache
	private let imageLoader: ImageLoader
	private let operationQueue = OperationQueue()
	
	init(imageCache: ImageCache, imageLoader: ImageLoader) {
		self.imageCache = imageCache
		self.imageLoader = imageLoader
		
		operationQueue.underlyingQueue = .global()
		operationQueue.maxConcurrentOperationCount = Constants.maxConcurrentOperationCount
	}
	
	// MARK: Cache
	
	/// Fast way to check if there is cached image by URL request and filter.
	public func hasCache(for urlRequest: URLRequest, with filter: ImageFilter? = nil) -> Bool {
		filter.flatMap { imageCache.imageSource(for: urlRequest, with: $0.identifier) }
			?? imageCache.imageSource(for: urlRequest) != nil
	}
	
	// MARK: Original image
	
	/// Provides original image by URL request.
	public func image(for urlRequest: URLRequest) async throws -> UIImage {
		// Try to get decoded image from cache
		do {
			let image = await operationQueue.awaitOperation {
				imageCache
					.localURL(for: urlRequest)
					.flatMap { try? Data(contentsOf: $0) }
					.flatMap(UIImage.makeWithScreenScale)
			}
			
			if let image = image { return image }
		}
		
		// Download image data
		try Task.checkCancellation()
		let data = try await imageLoader.imageData(for: urlRequest)
		
		// Create image from data and save it to cache
		try Task.checkCancellation()
		return try await operationQueue.awaitOperation {
			try originalImage(from: data, for: urlRequest)
		}
	}
	
	/// Creates image from data and saves it to cache.
	private func originalImage(from data: Data, for urlRequest: URLRequest) throws -> UIImage {
		// Try to get decoded image from data
		guard let image = UIImage.makeWithScreenScale(from: data) else {
			throw ImageProviderError.incorrectImageResponse
		}
		
		// Save image data to cache
		try? imageCache.storeImage(with: data, for: urlRequest)
		
		return image
	}
	
	/// Prefetch image by url request if needed.
	public func prefetchImage(for urlRequest: URLRequest) async throws {
		guard !hasCache(for: urlRequest) else { return }
		
		// Download image data
		let data = try await imageLoader.imageData(for: urlRequest)
		
		try await operationQueue.awaitOperation {
			// Check if image data is valid
			guard UIImage.makeWithScreenScale(from: data) != nil else {
				throw ImageProviderError.incorrectImageResponse
			}
			
			// Save image data to cache
			try imageCache.storeImage(with: data, for: urlRequest)
		}
	}
	
	// MARK: Filtered image
	
	/// Provides filtered image by URL request.
	public func image(for urlRequest: URLRequest, filter: ImageFilter, cachePolicy: FilteredImageCachePolicy = .both()) async throws -> UIImage {
		// Try to get filtered image from cache
		do {
			let image = try await operationQueue.awaitOperation {
				try imageCache.filteredImage(for: urlRequest, with: filter, saveDataFormat: cachePolicy.cacheFilteredFormat)
					.map(UIImage.makeWithScreenScale)
			}
			
			if let image = image { return image }
		}
		 
		// Download image data
		try Task.checkCancellation()
		let data = try await imageLoader.imageData(for: urlRequest)
		
		// Create filtered image from data and cache it
		try Task.checkCancellation()
		return try await operationQueue.awaitOperation {
			try filteredImage(from: data, for: urlRequest, filter: filter, cachePolicy: cachePolicy)
		}
	}
	
	/// Creates filtered image from data and caches it to cache.
	private func filteredImage(from data: Data, for urlRequest: URLRequest, filter: ImageFilter, cachePolicy: FilteredImageCachePolicy) throws -> UIImage {
		guard let imageSource = CGImageSource.make(with: data) else {
			throw ImageProviderError.incorrectImageResponse
		}
		
		// Process image with filter. If processed image is `nil` then process as original image
		guard let filteredImage = try filter.process(imageSource) else {
			return try originalImage(from: data, for: urlRequest)
		}
		
		// Save image data to cache
		if cachePolicy.cacheOriginal {
			try? imageCache.storeImage(with: data, for: urlRequest)
		}
		
		if let data = cachePolicy.cacheFilteredFormat.flatMap(filteredImage.makeData) {
			try? imageCache.storeImage(with: data, for: urlRequest, with: filter.identifier)
		}
		
		return .makeWithScreenScale(from: filteredImage)
	}
	
}

private extension UIImage {
	
	private static let mutex = NSLock()
	
	static func makeWithScreenScale(from data: Data) -> UIImage? {
		// There are thread-safety issues when initializing large amounts of images simultaneously
		mutex.lock()
		defer { mutex.unlock() }
		return UIImage(data: data, scale: UIScreen.main.scale)
	}
	
	static func makeWithScreenScale(from cgImage: CGImage) -> UIImage {
		UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
	}
	
}

public extension UIImage {
	/**
	 Scale the image to fit the given rectangle
	 */
	func aspectFitImage(inRect rect: CGRect) -> UIImage? {
		let imageFilter = ImageProvider.ImageFilter.thumbnail(targetSize: rect.size, scale: UIScreen.main.scale, layout: .fit)

		guard let imageData = pngData(), let imageSource = CGImageSource.make(with: imageData), let scaledImage = try? imageFilter.process( imageSource ) else {
			return self
		}

		return UIImage.makeWithScreenScale(from: scaledImage)
	}
}
