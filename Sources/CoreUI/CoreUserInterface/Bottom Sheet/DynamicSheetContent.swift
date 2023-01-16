//
//  DynamicSheetContent.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 11.11.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import UIKit

public protocol DynamicSheetContent: UIViewController {

	/// The `UIView` to which the panning gesture will be attached.
	var viewToHandlePanGesture: UIView { get }

	/// The whole size of the content we're embedding in the sheet.
	var contentSize: CGSize { get }

	/// `true` if the content of the sheet should be scrollable or not.
	var isScrollEnabled: Bool { get set }

	/// Used to allow the context decide when the bottom sheet should be displayed, based on its readyness.
	var contextDelegate: BottomSheetContextDelegate? { get set }

	/// Attaches an observer to the `contentSize` and notifies the `observationBlock` whenever there is a change.
	/// - Parameter observationBlock: Called with the new value of the `contentSize`.
	func addContentSizeChange( observationBlock: @escaping (CGSize) -> Void )

	/// Attaches a gesture recognizer  to a relevant `view` that, when interacted with, will allow the user to toggle between the states of the `bottom sheet`.
	/// - Parameter tapGestureRecognizer: A `UITapGestureRecognizer`.
	func addTogglingGesture( _ tapGestureRecognizer: UITapGestureRecognizer )

	/// Disables the `cancelsTouchesInView` in all gesture recognizers to avoid problems with touches since default value for `cancelsTouchesInView` is `true`.
	func disableCancelTouchesForAllGestures()

	/// Called when the container that the content will be embedded into will be expanded on the screen.
	func sheetWillExpand()

	/// Called when the container that the content will be embedded into will be collapsed on the screen.
	func sheetWillCollapse()
}

// Default empty implementation of the methods since it's not explicitly needed in every place that it's implemented.
public extension DynamicSheetContent {

	func sheetWillExpand() { }
	func sheetWillCollapse() { }
}
