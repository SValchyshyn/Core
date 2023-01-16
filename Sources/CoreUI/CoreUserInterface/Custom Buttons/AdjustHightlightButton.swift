//
//  AdjustHightlightButton.swift
//  CoopM16
//
//  Created by Jens Willy Johannsen on 18/08/2016.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit

public class AdjustHightlightButton: UIButton {
	private struct Constants {
		/// Alpha used for subviews when the cell is highlighted
		static let highlightedAlpha: CGFloat = 0.5
	}

	@IBOutlet var adjustableViews: [UIView]!

	override public var isHighlighted: Bool {
		didSet {
			// Only modify the alpha of the views if `isHighlighted` has changed
			guard isHighlighted != oldValue, let adjustableViews = adjustableViews else {
				return
			}

			for view in adjustableViews {
				if isHighlighted {
					// Reduce the view's opacity
					view.alpha = Constants.highlightedAlpha
				} else {
					// Make sure the view's has full opacity
					view.alpha = 1
				}
			}
		}
	}
}
