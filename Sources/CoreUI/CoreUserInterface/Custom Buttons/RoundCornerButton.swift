//
//  RoundCornerButton.swift
//  CoopM16
//
//  Created by Niels Nørskov on 04/05/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import Core

@IBDesignable open class RoundCornerButton: UIButton {
	@InjectableSafe
	fileprivate var layoutProvider: LayoutProtocol?

	/// Pixels padding on either side of normal instinsic content size.
	@IBInspectable public var horizontalBorderPadding: CGFloat = 20
	@IBInspectable public var showDropshadow: Bool = false
	
	@IBInspectable public var showBorder: Bool = true {
		didSet {
			if showBorder {
				layer.borderWidth = layoutProvider?.buttonBorderWidth ?? 0
				layer.borderColor = titleColor( for: self.state )?.cgColor
			} else {
				layer.borderWidth = 0
			}
		}
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()

		// Customize border
		customInit()
	}

	public convenience init( horizontalBorderPadding: CGFloat ) {
		self.init( frame: .zero )

		// Set the customizations.
		self.horizontalBorderPadding = horizontalBorderPadding

		// Perform the customization.
		self.customInit()
	}

	public override init( frame: CGRect ) {
		super.init( frame: frame )
		
		// Customizing border
		customInit()
	}
	
	public required init?( coder: NSCoder ) {
		super.init( coder: coder )
	}
	
	override public func prepareForInterfaceBuilder() {
		// Customize border
		customInit()
	}

	override public var intrinsicContentSize: CGSize {
		// Add horizontal padding if showing border
		var size = super.intrinsicContentSize

		if showBorder {
			size.width += 2 * horizontalBorderPadding
		}

		return size
	}

	override open var isEnabled: Bool {
		// Update the border color
		didSet {
			if showBorder {
				layer.borderColor = titleColor( for: self.state )?.cgColor
			}
		}
	}

	override public func setTitleColor( _ color: UIColor?, for state: UIControl.State ) {
		super.setTitleColor( color, for: state )
		if showBorder {
			layer.borderColor = titleColor( for: .normal )?.cgColor
		}
	}

	open func customInit() {
		
		if let cornerRadius = layoutProvider?.buttonCornerRadius,
			cornerRadius > frame.height / 2 || (frame.height - (cornerRadius*2)) < cornerRadius   {
			layer.cornerRadius = frame.height / 2
		} else {
			layer.cornerRadius = layoutProvider?.buttonCornerRadius ?? 0
		}

		if showBorder {
			layer.borderWidth = layoutProvider?.buttonBorderWidth ?? 0
			layer.borderColor = titleColor( for: self.state )?.cgColor // Use title colors border color
		}

		if showDropshadow {
			layer.shadowColor = Theme.Shadow.color
			layer.shadowOpacity = Theme.Shadow.opacity
			layer.shadowRadius = Theme.Shadow.radius
			layer.shadowOffset = Theme.Shadow.offset
		}
	}
}
