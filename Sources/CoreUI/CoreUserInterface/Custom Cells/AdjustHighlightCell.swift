//
//  AdjustHighlightCell.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 15/08/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit

/**
Class which all table view cells which support highlighting should inherit from.
The subviews which will be faded out should be added to the `adjustableViews` `IBOutletCollection`.
*/
open class AdjustHighlightCell: UITableViewCell {
	private struct Constants {
		/// Alpha used for subviews when the cell is highlighted
		static let highlightedAlpha: CGFloat = 0.5
	}

	@IBOutlet public var adjustableViews: [UIView]!

	open override func setHighlighted( _ highlighted: Bool, animated: Bool ) {
		super.setHighlighted( highlighted, animated: animated )

		if adjustableViews != nil {
			for view in adjustableViews {
				if highlighted {
					// Reduce the view's opacity
					view.alpha = Constants.highlightedAlpha
				} else {
					// Make sure the view has full opacity
					view.alpha = 1
				}
			}
		}
	}

	open override func setSelected( _ selected: Bool, animated: Bool ) {
		super.setSelected( selected, animated: animated )

		if adjustableViews != nil {
			for view in adjustableViews {
				if selected {
					// Reduce the view's opacity
					view.alpha = Constants.highlightedAlpha
				} else {
					// Make sure the view has full opacity
					view.alpha = 1
				}
			}
		}
	}
}
