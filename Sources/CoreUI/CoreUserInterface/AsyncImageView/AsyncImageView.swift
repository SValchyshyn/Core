//
//  AsyncImageView.swift
//  CoreUserInterface
//
//  Created by Jens Willy Johannsen on 17/12/14.
//  Copyright (c) 2014 Greener Pastures. All rights reserved.
//

import UIKit
import CoreNetworking

open class AsyncImageView: UIImageView {
	
	public typealias Completion = (Result<UIImage, Error>) -> Void
	
	public struct ImageTransition {
		
		public static func fadeIn(duration: TimeInterval) -> ImageTransition {
			ImageTransition { imageView, image in
				transition(with: imageView, duration: duration, options: .transitionCrossDissolve, animations: {
					imageView.image = image
				})
			}
		}
		
		fileprivate let animator: (AsyncImageView, UIImage) -> Void
		
	}
	
	/// Loading task. Store for cancellation.
	private var loadTask: Task<Void, Error>? {
		willSet { loadTask?.cancel() }
	}
	
	/// Image provider for loading images
	open var imageProvider: ImageProvider = .shared
	
	/// Use image view size for creation image thubnails
	@IBInspectable open var scaleImage: Bool = true
	
	/// Placeholder whilte loading image
	@IBInspectable open var placeholder: UIImage?
	
	/// Image transition for updating loaded image
	open var imageTransition: ImageTransition?
	
	/// Use image transition when setting image from image provider cache
	open var runImageTransitionIfCached = false
	
	/// Rendering mode that will be applied for image after load.
	open var imageRenderingMode: UIImage.RenderingMode?
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		
		layer.drawsAsynchronously = true
	}
	
	// MARK: Load image
	
	open func loadImage(for url: URL, completion: Completion?) {
		loadImage(for: URLRequest(url: url), completion: completion)
	}
	
	open func loadImage(for url: URL) {
		loadImage(for: URLRequest(url: url), completion: nil)
	}
	
	open func loadImage(for urlRequest: URLRequest, completion: Completion? = nil) {
		loadTask = Task { [imageProvider, placeholder, runImageTransitionIfCached, imageFilter] in
			do {
				// Check cancellation before start
				try Task.checkCancellation()
				
				// Check if there is image in cache
				let isCached = imageProvider.hasCache(for: urlRequest, with: imageFilter)
				
				// Set placeholder if not cached
				if let placeholder = placeholder, !isCached {
					try fulfill(with: placeholder, useTransition: false)
				}
				
				// Check cancellation fetching image
				try Task.checkCancellation()
				
				// Get image from image provider
				var image: UIImage = try await {
					if let filter = imageFilter {
						return try await imageProvider.image(for: urlRequest, filter: filter, cachePolicy: .both())
					} else {
						return try await imageProvider.image(for: urlRequest)
					}
				}()
				
				// Apply rendering mode
				if let imageRenderingMode {
					image = image.withRenderingMode(imageRenderingMode)
				}
				
				// Set image
				try fulfill(with: image, useTransition: !isCached || runImageTransitionIfCached)
				
				completion?(.success(image))
			} catch {
				completion?(.failure(error))
			}
		}
	}
	
	open func cancelLoading() {
		loadTask = nil
	}
	
	private var imageFilter: ImageProvider.ImageFilter? {
		guard scaleImage else { return nil }
		return .thumbnail(targetSize: bounds.size, scale: UIScreen.main.scale, layout: contentMode.thumbnailLayout)
	}
	
	// MARK: Update image
	
	@MainActor private func fulfill(with image: UIImage, useTransition: Bool) throws {
		try Task.checkCancellation()
		
		if useTransition, let transition = imageTransition {
			transition.animator(self, image)
		} else {
			self.image = image
		}
	}
	
	deinit {
		loadTask?.cancel()
	}
	
}

private extension UIView.ContentMode {
	
	var thumbnailLayout: ImageProvider.ImageFilter.ThumbnailLayout {
		[.scaleToFill, .scaleAspectFill].contains(self) ? .fill : .fit
	}
	
}
