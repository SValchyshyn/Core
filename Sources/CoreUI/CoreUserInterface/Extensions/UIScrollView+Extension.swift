//
//  UIScrollView+Extension.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 17.02.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import UIKit

public extension UIScrollView {

	/// Scrolls to the origin relative to the content; that is instead of using `CGPoint.zero`, which is the absolute origin,
	/// we're constructing the point at which to scroll from the `.left` and `.top` `contentInset` values.
	/// - Parameter animated: `true` if the scroll should be animated. Default value: `false`.
	func scrollToContentOrigin( animated: Bool = false ) {
		setContentOffset( .init( x: -contentInset.left, y: -contentInset.top ), animated: animated )
	}
}
