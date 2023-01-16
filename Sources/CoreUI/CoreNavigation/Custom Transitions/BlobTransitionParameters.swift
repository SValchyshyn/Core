//
//  BlobTransitionParameters.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 10/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

/// Information used by the blob expanding/ collapsing transition animation.
public struct BlobTransitionParameters {
	/// Frame of the blob which we want the expansion/ collapsing animation to overlap perfecly to.
	public let frame: CGRect

	/// Color of the blob to which we want to blend in during the transition. Default color: `Theme.Colors.coopRed`.
	public let color: UIColor?

	// MARK: - Init.

	public init( frame: CGRect, color: UIColor? ) {
		self.frame = frame
		self.color = color
	}
}
