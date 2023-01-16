//
//  BottomSheetDelegate.swift
//  CoreUserInterface
//
//  Created by Ievgen Goloboiar on 16.07.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

/// Provides an interface to interact with the `bottomSheet` and manipulate it's appearance on the screen.
public protocol BottomSheetDelegate: AnyObject {
	
	/// Returns the sheet view
	var sheetView: UIView? { get }
	
	/// Hides the bottom sheet.
	/// - Parameter completion: Called after the animation is completed.
	func hideBottomSheet( _ completion: (() -> Void)? )

	/// Makes the bottom sheet visible on the screen, if not already. If the state from which we're transitioning is not `.hidden` then
	/// this has no effect on the bottom sheet visibility.
	/// - Parameter completion: Called after the animation is completed.
	func unhideBottomSheet( _ completion: (() -> Void)? )

	/// Collapse bottom sheet. Can potentially unhide the bottom sheet as well. No effect if the bottom sheet is already `collapsed`.
	/// - Parameter animationDuration: Custom duration of the sheet snapping.
	/// - Parameter completion: Called after the animation is completed.
	func collapseBottomSheet( animationDuration: TimeInterval, _ completion: (() -> Void)? )
	
	/// Expand bottom sheet. Can potentially unhide the bottom sheet as well. No effect if the bottom sheet is already `expanded`.
	/// - Parameter animationDuration: Custom duration of the sheet snapping.
	/// - Parameter completion: Called after the animation is completed.
	func expandBottomSheet( animationDuration: TimeInterval, _ completion: (() -> Void)? )
}
