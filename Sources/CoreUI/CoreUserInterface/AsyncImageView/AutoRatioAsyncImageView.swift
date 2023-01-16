//
//  AutoRatioAsyncImageView.swift
//  CoreUserInterface
//
//  Created by Roman Croitor on 21.10.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit

public class AutoRatioAsyncImageView: AsyncImageView {
	
	private var imageRatioConstraint: NSLayoutConstraint?
	
	public var rationConstraintPriority: UILayoutPriority = .required
	
	public override var image: UIImage? {
		didSet { imageDidChange() }
	}
	
	private func imageDidChange() {
		imageRatioConstraint?.isActive = false
		imageRatioConstraint.map(removeConstraint)
		imageRatioConstraint = nil
		
		if let imageSize = image?.size {
			let ratio = imageSize.height / imageSize.width
			imageRatioConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: ratio)
			imageRatioConstraint?.priority = rationConstraintPriority
			imageRatioConstraint?.isActive = true
		}
	}
}
