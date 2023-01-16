//
// Created by Roland Leth on 26/08/2019.
// Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

public extension UIView {

	/// Shorthand syntax for `translatesAutoresizingMaskIntoConstraints`.
	var usesAutoLayout: Bool {
		get { return !translatesAutoresizingMaskIntoConstraints }
		set { translatesAutoresizingMaskIntoConstraints = !newValue }
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and activates an array of constraints.

	- Parameter constraints: The constraints to activate.
	*/
	func activate(_ constraints: [NSLayoutConstraint]) {
		usesAutoLayout = true
		NSLayoutConstraint.activate(constraints)
	}

	/**
	Adds `self` to a view and activates an array of constraints.

	- Parameter parent: The view to add as a child.
	- Parameter constraints: The constraints to activate.
	*/
	func add(to parent: UIView, activating constraints: [NSLayoutConstraint]) {
		parent.addSubview(self)
		activate(constraints)
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and creates a `centerY` and a `centerX` constraint with another view. Does not activate.

	- Parameter view: The view to align `self` with.
	*/
	func alignCenter(with view: UIView) -> [NSLayoutConstraint] {
		usesAutoLayout = true

		return [
			centerYAnchor.constraint(equalTo: view.centerYAnchor),
			centerXAnchor.constraint(equalTo: view.centerXAnchor)
		]
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and creates a `leadingAnchor` and a `trailingAnchor` constraint with another view. Does not activate.

	- Parameter view: The view to align `self` with.
	*/
	func alignHorizontally(with view: UIView, constant: CGFloat = 0) -> [NSLayoutConstraint] {
		usesAutoLayout = true

		return [
			leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant),
			trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -constant)
		]
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and creates a `leadingAnchor` and a `trailingAnchor` constraint with a layout guide. Does not activate.

	- Parameter view: The layout guide to align `self` with.
	*/
	func alignHorizontally(with guide: UILayoutGuide, constant: CGFloat = 0) -> [NSLayoutConstraint] {
		usesAutoLayout = true

		return [
			leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: constant),
			trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -constant)
		]
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and creates a `topAnchor` and a `bottomAnchor` constraint with another view. Does not activate.

	- Parameter view: The view to align `self` with.
	*/
	func alignVertically(with view: UIView, constant: CGFloat = 0) -> [NSLayoutConstraint] {
		usesAutoLayout = true

		return [
			topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
			bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant)
		]
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and creates a `topAnchor` and a `bottomAnchor` constraint with a layout guide. Does not activate.

	- Parameter view: The layout guide to align `self` with.
	*/
	func alignVertically(with guide: UILayoutGuide, constant: CGFloat = 0) -> [NSLayoutConstraint] {
		usesAutoLayout = true

		return [
			topAnchor.constraint(equalTo: guide.topAnchor, constant: constant),
			bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -constant)
		]
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and creates a `leadingAnchor`, a `trailingAnchor`, a `topAnchor` and a `bottomAnchor` constraint with another view. Does not activate.

	- Parameter view: The layout guide to align `self` with.
	- Parameter constant: The value to use for the constraints.
	*/
	func align(with view: UIView, constant: CGFloat = 0) -> [NSLayoutConstraint] {
		return alignVertically(with: view, constant: constant)
			+ alignHorizontally(with: view, constant: constant)
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and creates a `leadingAnchor`, a `trailingAnchor`, a `topAnchor` and a `bottomAnchor` constraint with a layout guide. Does not activate.

	- Parameter view: The layout guide to align `self` with.
	- Parameter constant: The value to use for the constraints.
	*/
	func align(with guide: UILayoutGuide, constant: CGFloat = 0) -> [NSLayoutConstraint] {
		return alignVertically(with: guide, constant: constant)
			+ alignHorizontally(with: guide, constant: constant)
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and creates a `heightAnchor` and a `widthAnchor` constraint with another view. Does not activate.

	- Parameter view: The view to constrain `self` with.
	- Parameter multiplier: The multiplier to use for the constraints.
	- Parameter constant: The constant to use for the constraints.
	*/
	func constrainSize(with view: UIView, multiplier: CGFloat = 0, constant: CGFloat = 0) -> [NSLayoutConstraint] {
		usesAutoLayout = true

		return [
			heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: multiplier, constant: constant),
			widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier, constant: constant)
		]
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and creates a `heightAnchor` and a `widthAnchor` constraint based on a value. Does not activate.

	- Parameter value: The constant to use for the constraints.
	*/
	func constrainSize(to value: CGFloat) -> [NSLayoutConstraint] {
		usesAutoLayout = true

		return [
			widthAnchor.constraint(equalToConstant: value),
			heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
		]
	}

	/**
	Sets `translatesAutoresizingMaskIntoConstraints` to `false` and creates a `heightAnchor` and a `widthAnchor` constraint based on a size. Does not activate.

	- Parameter size: The size to use for the constraints.
	*/
	func constrainSize(to size: CGSize) -> [NSLayoutConstraint] {
		usesAutoLayout = true

		return [
			heightAnchor.constraint(equalToConstant: size.height),
			widthAnchor.constraint(equalToConstant: size.width)
		]
	}
	
	/**
	Pin the edges of the view to the edges of the given parent view. Also sets `translatesAutoresizingMaskIntoConstraints = false`.
	*/
	func pinEdges(to parent: UIView) {
		NSLayoutConstraint.activate(align(with: parent))
	}

	/**
	 Pin the edges of the view to the edges of the given layout guide. Also sets `translatesAutoresizingMaskIntoConstraints = false`.

	- Parameter layoutGuide: The layout guide to align `self` with.
	- Parameter constant: The value to use for the constraints.
	*/
	func pinEdges(to layoutGuide: UILayoutGuide, constant: CGFloat = 0) {
		NSLayoutConstraint.activate(align(with: layoutGuide, constant: constant))
	}

}
