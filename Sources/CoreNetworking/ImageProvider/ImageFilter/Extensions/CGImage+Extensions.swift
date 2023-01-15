//
//  CGImage+Extensions.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 12.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import ImageIO

extension CGImage {
	
	public enum DataFormat: Hashable {
		
		case png
		case jpeg(compressionQuality: CGFloat)
		case heic(compressionQuality: CGFloat)
		
		fileprivate var uti: String {
			switch self {
			case .png: return "public.png"
			case .jpeg: return "public.jpeg"
			case .heic: return "public.heic"
			}
		}
		
		var compressionQuality: CGFloat? {
			switch self {
			case .jpeg(let compressionQuality), .heic(let compressionQuality):
				return compressionQuality
				
			case .png:
				return nil
			}
		}
		
	}
	
	func makeData(with format: DataFormat) -> Data? {
		let data = NSMutableData()
		guard let destination = CGImageDestinationCreateWithData(data, format.uti as CFString, 1, nil) else { return nil }

		var options: NSDictionary?
		if let compressionQuality = format.compressionQuality {
			options = [kCGImageDestinationLossyCompressionQuality: compressionQuality]
		}

		CGImageDestinationAddImage(destination, self, options)
		guard CGImageDestinationFinalize(destination) else { return nil }

		return data as Data
	}
	
}
