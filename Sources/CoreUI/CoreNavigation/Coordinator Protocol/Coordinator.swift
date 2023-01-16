//
//  Coordinator.swift
//  CoopCore
//
//  Created by Frederik Sørensen on 27/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

/// A type that coordinates different transitions.
///
/// A `Coordinator` may contain any number of children (usually just one, unless for tab bar coordinators).
///
/// All `Coordinator`s should have a parent `Coordinator`, except for the top coordinator. The `Coordinator`s must tell their parent once their coordination is complete through the parent's `childDidFinish(_:)`.
///
/// The parent keeps a strong reference to their children, hence the children should not keep strong references to their parents. The `parentCoordinator` property should be implemented as weak
public protocol Coordinator: AnyObject {
	/// The `Coordinator`'s parent, if any.
	///
	/// - Important: This relationship should be weak.
	var parentCoordinator: Coordinator? { get set }

	/// The `Coordinator`'s children
	var childCoordinators: [Coordinator] { get set }

	/// A convenience function that sets the provided `Coordinator`s `parentCoordinator` property and appends the coordinator to the `childCoordinators` array.
	func addChild(_ child: Coordinator)

	/// A function to invoke by child coordinators on their parent, once they are finished.
	///
	/// This method should remove the reference to the child and let it deallocate. A standard implementation is provided
	///
	/// - Parameter child: The child coordinator that finished.
	func childDidFinish(_ child: Coordinator)

	/// A function to invoke in order to start the coordinator's flow.
	///
	/// When this method is invoked, the coordinator's `parentCoordinator` should have been set, if there is one.
	func start()
}

extension Coordinator {
	public func childDidFinish(_ child: Coordinator) {
		if let index = childCoordinators.firstIndex(where: { $0 === child }) {
			// Remove the reference
			childCoordinators.remove(at: index)
		}
	}

	public func addChild(_ child: Coordinator) {
		child.parentCoordinator = self
		childCoordinators.append(child)
	}
}

/// `Coordinator` which provides the ability to navigates backwards in the flow.
public protocol BackwardsNavigationCoordinator: Coordinator {

	/// Navigates to the previous screen based on how it was presented.
	/// - Parameters:
	///   - viewController: The `viewController` requesting the back action.
	///   - animated: `true` if the navigation should be animated.
	///   - completion: Called after the dismiss animation is performed. Called instantly if `animated == false` or we're `popping` a viewController from the navigation stack. Default value: `nil`.
	func goBack( from viewController: UIViewController, animated: Bool, completion: (() -> Void)? )
}
