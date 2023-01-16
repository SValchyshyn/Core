//
//  UIStackView-Extensions.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 03/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

public extension UIStackView {
	/**
	Extension.
	Iterate over all arranged subviews.
	Remove each one from array and from superview (this StackView).
	*/
	func removeAllArrangedSubviews2() {
		arrangedSubviews.forEach { view in
			removeArrangedSubview( view )
			view.removeFromSuperview()
		}
	}

	/**
	Extension.
	Iterate over all arranged subviews.
	Remove each one from array and from superview (this StackView).
	- parameter type: Only remove views of the provided type.
	*/
	func removeAllArrangedSubviews<T: UIView>( of type: T.Type ) {
		arrangedSubviews
			.filter { $0 is T }
			.forEach { view in
				removeArrangedSubview( view )
				view.removeFromSuperview()
		}
	}

	/// Returns the list of views of particular type arranged by the stack view.
	/// - Parameter type: Type of arranged subviews to be returned.
	/// - Returns: An array of arranged subviews of particular type.
	func arrangedSubviews<T: UIView>(of type: T.Type) -> [T] {
		return arrangedSubviews.compactMap { $0 as? T }
	}

	/// Sets views as arranged subviews of stack view and removes existing ones, if present.
	/// - Parameter views: Views to be added to the array of views arranged by the stack.
	func setArrangedSubviews(_ views: [UIView]) {
		removeAllArrangedSubviews2()
		views.forEach { addArrangedSubview($0) }
	}
}
