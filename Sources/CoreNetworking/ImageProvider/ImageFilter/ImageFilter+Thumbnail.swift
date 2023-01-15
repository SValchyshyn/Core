//
//  ImageFilter+Thumbnail.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 12.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import ImageIO

extension ImageProvider.ImageFilter {
	
	public enum ThumbnailLayout {
		/// The option to scale the image to fill the target size.
		case fill
		/// The option to scale the image to fit the target size.
		case fit
	}
	
	/// Creates thumbnail filter with target size.
	public static func thumbnail(targetSize: CGSize, scale: CGFloat, layout: ThumbnailLayout = .fill) -> Self {
		let size = CGSize(width: targetSize.width * scale, height: targetSize.height * scale)
		return thumbnail(targetSize: size, layout: layout)
	}
	
	/// Creates thumbnail filter with target size.
	public static func thumbnail(targetSize: CGSize, layout: ThumbnailLayout = .fill) -> Self {
		let identifier: String = {
			switch layout {
			case .fit: return "thumbnail-fit-\(targetSize.width)-\(targetSize.height)"
			case .fill: return "thumbnail-fill-\(max(targetSize.width, targetSize.height))"
			}
		}()
		
		return Self(identifier: identifier) { source in
			let maxPixelLength: CGFloat = {
				guard let sourceSize = source.size, layout == .fit else {
					return max(targetSize.width, targetSize.height)
				}
				
				let targetRatio = targetSize.width / targetSize.height
				let sourceRatio = sourceSize.width / sourceSize.height
				
				if targetRatio == 1 {
					return min(targetSize.width, max(sourceSize.width, sourceSize.height))
				}
				
				switch (targetRatio > 1, sourceRatio > 1) {
				case (true, true) where targetRatio > sourceRatio:
					return min(sourceSize.width / (sourceSize.height / targetSize.height), sourceSize.width)
					
				case (false, false) where targetRatio < sourceRatio:
					return min(sourceSize.height / (sourceSize.width / targetSize.width), sourceSize.height)
					
				case (_, true):
					return min(targetSize.width, sourceSize.width)
					
				case (_, false):
					return min(targetSize.height, sourceSize.height)
				}
			}()
			
			return thumbnail(from: source, maxPixelLength: Int(maxPixelLength))
		}
	}
	
	private static func thumbnail(from source: CGImageSource, maxPixelLength: Int) -> CGImage? {
		if let sourceMaxPixelSize = source.maxPixelSize, sourceMaxPixelSize <= maxPixelLength {
			return nil // Use original
		}
		
		return source.makeThumbnail(with: maxPixelLength)
	}
	
}
