//
//  ShadowView.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 21/05/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

/**
View with Interface Builder exposed properties for shadow configuration
*/
@IBDesignable public class ShadowView: UIView {
	@IBInspectable public var shadowColor: UIColor? {
		get {
			if let color = layer.shadowColor {
				return UIColor( cgColor: color )
			}
			return nil
		}
		set {
			if let color = newValue {
				layer.shadowColor = color.cgColor
			} else {
				layer.shadowColor = nil
			}
		}
	}

	@IBInspectable public var shadowRadius: CGFloat {
		get {
			return layer.shadowRadius
		}
		set {
			layer.shadowRadius = newValue
		}
	}

	@IBInspectable public var shadowOffset: CGSize {
		get {
			return layer.shadowOffset
		}
		set {
			layer.shadowOffset = newValue
		}
	}
	
	@IBInspectable public var shadowOpacity: Float {
		get {
			return layer.shadowOpacity
		}
		set {
			layer.shadowOpacity = newValue
		}
	}
}
