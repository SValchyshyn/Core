//
//  ImageCache+Filtered.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 13.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import ImageIO

extension ImageCache {
	
	/// Returns filtered image by url request.
	func filteredImage(for urlRequest: URLRequest, with filter: ImageProvider.ImageFilter, saveDataFormat: CGImage.DataFormat?) throws -> CGImage? {
		// Try to fetched cached filtered image
		if let filteredImage = imageSource(for: urlRequest, with: filter.identifier)?.makeImage() {
			return filteredImage
		}
		
		// Try to get original image
		guard let originalImageSource = imageSource(for: urlRequest) else {
			return nil
		}
		
		// Try to apply filter to original image. If `nil` then use original image
		guard let filteredImage = try filter.process(originalImageSource) else {
			return originalImageSource.makeImage()
		}
		
		// Save filtered image if needed
		if let dataFormat = saveDataFormat, let data = filteredImage.makeData(with: dataFormat) {
			try? storeImage(with: data, for: urlRequest, with: filter.identifier)
		}
		
		return filteredImage
	}
	
}
