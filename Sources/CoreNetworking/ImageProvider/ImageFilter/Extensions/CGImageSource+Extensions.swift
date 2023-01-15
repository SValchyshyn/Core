//
//  CGImageSource+Extensions.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 12.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import ImageIO

extension CGImageSource {
	
	// MARK: Init
	
	static func make(with fileURL: URL) -> CGImageSource? {
		guard let data = try? Data(contentsOf: fileURL) else { return nil }
		return .make(with: data)
	}
	
	static func make(with data: Data) -> CGImageSource? {
		CGImageSourceCreateWithData(data as CFData, nil)
	}
	
	// MARK: Size
	
	public var size: CGSize? {
		guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(self, 0, nil) as? [CFString: Any],
			  let pixelWidth = imageProperties[kCGImagePropertyPixelWidth],
			  let pixelHeight = imageProperties[kCGImagePropertyPixelHeight]
			else { return nil }
		
		var size = CGSize.zero

		// swiftlint:disable:next force_cast_gp
		CFNumberGetValue((pixelWidth as! CFNumber), .cgFloatType, &size.width)
		// swiftlint:disable:next force_cast_gp
		CFNumberGetValue((pixelHeight as! CFNumber), .cgFloatType, &size.height)

		if let orientationNumber = imageProperties[kCGImagePropertyOrientation] {
			var orientation: CGFloat = 0
			// swiftlint:disable:next force_cast_gp
			CFNumberGetValue((orientationNumber as! CFNumber), .intType, &orientation)
			// Check orientation and flip size if required
			if orientation > 4 { let temp = size.width; size.width = size.height; size.height = temp }
		}

		return size
	}
	
	var maxPixelSize: Int? {
		size.map { max($0.width, $0.height) }.map(Int.init)
	}
	
	// MARK: Image
	
	func makeImage() -> CGImage? {
		CGImageSourceCreateImageAtIndex(self, 0, nil)
	}
	
	// MARK: Thumbnail
	
	func makeThumbnail(with maxPixelSize: Int) -> CGImage? {
		let options = [
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceCreateThumbnailWithTransform: true,
			kCGImageSourceShouldCacheImmediately: true,
			kCGImageSourceThumbnailMaxPixelSize: maxPixelSize] as CFDictionary
		
		return CGImageSourceCreateThumbnailAtIndex(self, 0, options)
	}
	
}
