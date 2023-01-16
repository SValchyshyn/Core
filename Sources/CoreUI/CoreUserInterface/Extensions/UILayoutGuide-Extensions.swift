//
//  UILayoutGuide-Extensions.swift
//  CoreUserInterface
//
//  Created by Valeriy Kolodiy on 07.06.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit

public extension UILayoutGuide {

	/// Pin the edges of the layout guide to the edges of the given view.
	/// - Parameters:
	///   - view: A UIView to pin the layout guide to.
	///   - constant: The value to use for the constraints.
	func pinEdges(to view: UIView, constant: CGFloat = 0) {
		NSLayoutConstraint.activate([
			topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
			bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant),
			leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant),
			trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -constant)
		])
	}

}
