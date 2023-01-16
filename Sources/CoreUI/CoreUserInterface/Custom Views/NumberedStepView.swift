//
//  NumberedStepView.swift
//  CoopUI
//
//  Created by Georgi Damyanov on 22/09/2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit

/**
View with a step number and a title. Used when building a list of steps.
*/
public class NumberedStepView: UIView {
	@IBOutlet private weak var contentView: UIView!
	@IBOutlet public weak var stepLabel: UILabel!
	@IBOutlet public weak var contentLabel: UILabel!

	// MARK: - Init.

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	private func commonInit() {
		Bundle.CoreUIModule.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.frame = bounds
		addSubview(contentView)
		contentView.pinEdges(to: self)

		// Set the fonts
		stepLabel.font = fontProvider[.bold(.title)]
		contentLabel.font = fontProvider[.regular(.body)]
	}
}
