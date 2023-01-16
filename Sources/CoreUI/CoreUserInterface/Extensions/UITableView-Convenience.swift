//
//  UITableView-Convenience.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 21/12/2018.
//  Copyright © 2018 Greener Pastures. All rights reserved.
//

import UIKit

/**
Simplified way for getting a nib and reuse identifier. As described here: https://www.natashatherobot.com/swift-3-0-refactoring-cues/
*/
public protocol NibLoadableView: AnyObject {}
public protocol ReusableView: AnyObject {}

public extension NibLoadableView where Self: UIView {
	static var nib: UINib {
		return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
	}
}

public extension ReusableView where Self: UIView {
	static var reuseIdentifier: String {
		return String(describing: self)
	}
}

public extension UITableView {
	/// Convenience method for registering a `UITableViewCell` type
	func register<T: UITableViewCell>(_ type: T.Type) {
		register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
	}

	/// Convenience method for dequeuing a `UITableViewCell` type
	func dequeue<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
		return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T // Caller ensures correct type and that the cell has been registered -FSO
	}

	/// Convenience method for registering a `UITableViewHeaderFooterView` type
	func register<T: UITableViewHeaderFooterView>(_ type: T.Type) {
		register(T.nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
	}

	/// Convenience method for dequeuing a `UITableViewHeaderFooterView` type
	func dequeue<T: UITableViewHeaderFooterView>(_ type: T.Type) -> T {
		return dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
	}
}

public extension UICollectionView {
	/// Convenience method for registering a `UICollectionViewCell` type
	func register<T: UICollectionViewCell>(_ type: T.Type) {
		register(T.nib, forCellWithReuseIdentifier: T.reuseIdentifier)
	}

	/// Convenience method for dequeuing a `UICollectionViewCell` type
	func dequeue<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
		return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T // Caller ensures correct type and that the cell has been registered -FSO
	}

	enum SupplementaryViewKind {
		case header, footer

		var rawValue: String {
			switch self {
			case .header:
				return UICollectionView.elementKindSectionHeader

			case .footer:
				return UICollectionView.elementKindSectionFooter
			}
		}
	}

	/// Convenience method for registering a `UICollectionReusableView` type
	func register<T: UICollectionReusableView>(_ type: T.Type, as kind: SupplementaryViewKind) {
		register(T.nib, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.reuseIdentifier)
	}

	/// Convenience method for dequeuing a `UICollectionReusableView` type
	func dequeue<T: UICollectionReusableView>(_ type: T.Type, for indexPath: IndexPath, as kind: SupplementaryViewKind) -> T {
		return dequeueReusableSupplementaryView( ofKind: kind.rawValue, withReuseIdentifier: T.reuseIdentifier, for: indexPath ) as! T // Caller ensures correct type and that the view has been registered -FSO
	}
}

/**
We want all our cells to have a `nib` and `reuseIdentifier` property.
*/
extension UITableViewCell: NibLoadableView, ReusableView {}
extension UICollectionReusableView: NibLoadableView, ReusableView {} // This is also UICollectionViewCells
extension UITableViewHeaderFooterView: NibLoadableView, ReusableView {}
