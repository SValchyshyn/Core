//
//  UIStoryboard+instantiateVC.swift
//  CoreUserInterface
//
//  Created by Nazariy Vlizlo on 07.07.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

public extension UIStoryboard {

	/// Creates the viewController using the class name.
	/// - note: Set ViewController's identifier as it's name (f.e. AusumnViewController.identifier == "AusumnViewController")
	func instantiate<T: UIViewController>(_ type: T.Type, creator: ((NSCoder) -> T?)? = nil) -> T {
		return instantiateViewController(identifier: String(describing: type.self), creator: creator)
	}

	/// Function for easily instantiating a view controller from its identifier.
	/// IMPORTANT: The view controller must have a storyboard identifier identical to its name
	func instantiate<T: UIViewController>(creator: ((NSCoder) -> T?)? = nil) -> T {
		return instantiateViewController(identifier: T.identifier, creator: creator)
	}
}

// MARK: - StoryboardIdentifiable

public protocol StoryboardIdentifiable {
	static var identifier: String { get }
}

public extension StoryboardIdentifiable where Self: UIViewController {

	/// Utility function for getting the view controller identifier based on the name of the class
	static var identifier: String { String( describing: self ) }
}

extension UIViewController: StoryboardIdentifiable {}
