//
//  ImageProvider+ImageFilter.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 12.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import ImageIO

extension ImageProvider {
	
	public struct ImageFilter {
		
		typealias Identifier = String
		typealias Processor = (CGImageSource) throws -> CGImage?
		
		let identifier: Identifier
		private let processor: Processor
		
		init(identifier: Identifier, processor: @escaping Processor) {
			self.identifier = identifier
			self.processor = processor
		}
		
		/// Returns filtered image. Return `nil` if filter is already applied to image source.
		func process(_ source: CGImageSource) throws -> CGImage? {
			try processor(source)
		}
		
	}
	
}
