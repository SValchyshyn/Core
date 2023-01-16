//
//  CustomLabel.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 16/05/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

/**
A superclass for all our custom labels.
*/
@IBDesignable open class CustomLabel: LineHeightLabel {

	required public init?( coder aDecoder: NSCoder ) {
		super.init( coder: aDecoder )
		customInit()
	}

	override init( frame: CGRect ) {
		super.init(frame: frame)
		customInit()
	}

	override open func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		customInit()
	}

	override open func awakeFromNib() {
		super.awakeFromNib()
		customInit()
	}
	
	open func customInit() { }
}
