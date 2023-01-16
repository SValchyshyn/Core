//
//  RoundedCornersView.swift
//  CoopUI
//
//  Created by Georgi Damyanov on 23/09/2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit

@IBDesignable open class RoundedCornersView: UIView {
	@IBInspectable public var cornerRadius: CGFloat = 0.0 {
		didSet {
			self.layer.cornerRadius = cornerRadius
		}
	}
}
