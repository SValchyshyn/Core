//
//  GradientView.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 26/06/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

@IBDesignable public class GradientView: UIView {
	@IBInspectable public var topColor: UIColor = UIColor.white
	@IBInspectable public var bottomColor: UIColor = UIColor.black

	public override class var layerClass: AnyClass {
		return CAGradientLayer.self
	}

	public override func layoutSubviews() {
		(layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]	// We did set the layerClass type to CAGradientLayer -GKD
	}
}
