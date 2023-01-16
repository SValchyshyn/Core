//
//  PlayButton.swift
//  CoopUI
//
//  Created by Georgi Damyanov on 16/06/2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import UIKit

/**
A button with a custom play icon
*/
@IBDesignable public class PlayButton: UIButton {
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

	override open func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		updateImage()
	}

	private func updateImage() {
		let bundle = Bundle( for: type( of: self ))

		let image = UIImage( named: "btn_play", in: bundle, compatibleWith: nil )?.withRenderingMode( .alwaysOriginal )
		setImage(image, for: .normal)
	}
}
