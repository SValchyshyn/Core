//
//  UIView+TopBarView.swift
//  Bonus
//
//  Created by Nazariy Vlizlo on 24.06.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit

extension UIView {
	/**
	Find and return the top bar view if the current view has one.
	*/
	public func topBarView() -> TopBarView? {
		return subviews.first { $0 is TopBarView } as? TopBarView
	}
}
