//
//  ExecutionBlockContainer.swift
//  CoopUI
//
//  Created by Georgi Damyanov on 10/02/2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

/**
Container for a block of code that has to be executed when its turn in the alert coordinator arrives.
*/
private struct AlertCoordinatorBlockContainer: AlertRepresenting {
	let block: AlertCoordinator.Block

	func present(overViewController: UIViewController, didDismiss: @escaping () -> Void ) {
		// Execute the block and once it is done move to the next alert.
		block {
			didDismiss()
		}
	}

	func isEqualTo(_ otherAlert: AlertRepresenting) -> Bool {
		// There is no meaningful way of comparing the block containers
		return false
	}
}

/**
Utility for scheduling a block of code as part of the alert queue.
*/
public extension AlertCoordinator {
	typealias Block = (@escaping () -> Void) -> Void

	/**
	Perform the given async block on code as part of the alert queue when its turn arrives.
	Remember to call the completion code when the block is done executing. ** Otherwise the alert queue will get stuck! **
	*/
	func performAsyncBlock(_ block: @escaping Block) {
		enqueue( AlertCoordinatorBlockContainer( block: block ))
	}
	
	/**
	Perform the given sync block on code as part of the alert queue when its turn arrives.
	*/
	func performBlock(_ block: @escaping () -> Void) {
		performAsyncBlock { completion in
			block()
			completion()
		}
	}
}
