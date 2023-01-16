//
//  UIImage+Extensions.swift
//  CoreUserInterface
//
//  Created by Ievgen Goloboiar on 15.07.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
	/**
	Mask image with mask.
	
	- parameter image:		Image to be masked.
	- parameter maskImage:	Mask to be applied to image. Mask must be black/white image. White parts are cut out of masked image.
	- returns:				Masked image.
	*/
	class func maskImage( _ image: UIImage?, maskImage: UIImage? ) -> UIImage? {
		guard let image = image, let maskImage = maskImage else {
			return nil
		}
		// Mask image with mask
		let maskRef = maskImage.cgImage
		let mask  = CGImage( maskWidth: (maskRef?.width)!, height: (maskRef?.height)!, bitsPerComponent: (maskRef?.bitsPerComponent)!, bitsPerPixel: (maskRef?.bitsPerPixel)!, bytesPerRow: (maskRef?.bytesPerRow)!, provider: (maskRef?.dataProvider!)!, decode: nil, shouldInterpolate: true )
		let masked  = image.cgImage?.masking(mask! )

		// Return masked image
		return (masked != nil) ? UIImage( cgImage: masked! ) : nil
	}

	/**
	Creates a copy of the image with the specified alpha.

	- parameter alpha: A CGFloat from 0 to 1.0 specifying the alpha of the image copy.
	- returns: A copy of the image with the specified alpha.
	*/
	func imageWithAlpha( _ alpha: CGFloat ) -> UIImage {
		UIGraphicsBeginImageContextWithOptions( self.size, false, UIScreen.main.scale )

		self.draw( in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height ), blendMode: .normal, alpha: alpha )
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image!
	}

	/// Grey image used as placeholder.
	static var placeholder: UIImage {
		return UIImage( named: "img_placeholder" )!
	}
	
	/**
	Create a image filled with a color.
	
	- parameter color: image color
	- parameter size: image size
	- returns: colored image
	*/
	convenience init?(size: CGSize, color: UIColor) {
		let bounds = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)

		var image: UIImage?
		let renderer = UIGraphicsImageRenderer(size: size)
		image = renderer.image { context in
			color.setFill()
			context.fill(bounds)
		}

		guard let outputImage = image, let cgImage = outputImage.cgImage else { return nil}
		self.init(cgImage: cgImage, scale: outputImage.scale, orientation: outputImage.imageOrientation)
	}
}
