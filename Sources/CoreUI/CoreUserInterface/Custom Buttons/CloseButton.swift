//
//  CloseButton.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 23/06/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import Core

@IBDesignable public class CloseButton: UIButton {
	@IBInspectable public var circleColor: UIColor = UIColor.white
	@IBInspectable public var circleDiameter: CGFloat = 33

	/// Changeing the value to `true` will set the image to light, otherwise the dark one.
	@IBInspectable public var isLight: Bool = false {
		didSet {
			updateImage()
		}
	}
	
	var coreAssetsContents: CoreAssetsCustomContents? = ServiceLocator.injectSafe()
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		updateImage()
	}

	public override init(frame: CGRect) {
		super.init( frame: frame )
		updateImage()
	}

	required init?(coder: NSCoder) {
		super.init( coder: coder )
		updateImage()
	}

	override public func draw( _ rect: CGRect ) {
		// Calculate a rect for the circle in the center of the button
		let rectForCircle = CGRect( x: rect.width/2 - circleDiameter/2, y: rect.height/2 - circleDiameter/2, width: circleDiameter, height: circleDiameter )

		// Create a path for the circle
		let path = UIBezierPath( ovalIn: rectForCircle )

		// Color the circle
		circleColor.setFill()
		path.fill()

		// Call super to draw the cross on top
		super.draw( rect )
		updateImage()
	}

	override open func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		updateImage()
	}

	/// Update button's image depending on the `isLight` value.
	private func updateImage() {
		imageView?.contentMode = .scaleAspectFit
		
		let closeImage = isLight ? coreAssetsContents?.lightCloseImage : coreAssetsContents?.darkCloseImage
		// Make sure default images are loaded from the CoreUserInterface assets, not the main project ones.
		let defaultCloseImageName = isLight ? "gfx-close" : "gfx-close-dark"
		
		var image = closeImage ?? instantiateImage(defaultCloseImageName)
		image = image.withRenderingMode(.alwaysOriginal)
		setImage(image, for: .normal)
	}
	
	/// Convenient method for instantiating images that must be available in `.xcassets` folder in current bundle
	private func instantiateImage(_ named: String) -> UIImage {
		let bundle = Bundle( for: type( of: self ))
		
		guard let image = UIImage( named: named, in: bundle, compatibleWith: nil ) else {
			fatalError("Image \"\(named)\" must exist in current bundle \(bundle)")
		}
		
		return image
	}
}
