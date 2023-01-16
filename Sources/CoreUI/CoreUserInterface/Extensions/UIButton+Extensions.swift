//
//  UIButton+Extensions.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 04.03.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

public extension UIButton {

	/// Has an effect noly for `ButtonType.system` buttons and removed the flashing that is automatically performed
	/// when setting a title.
	/// - Parameters:
	///   - title: The title to use for the specified state.
	///   - state: The state that uses the specified title. The possible values are described in UIControl.State.
	func setTitleWithoutAnimation( _ title: String?, for state: UIControl.State ) {
		UIView.performWithoutAnimation { [self] in
			setTitle( title, for: state )
			layoutIfNeeded()
		}
	}
}
