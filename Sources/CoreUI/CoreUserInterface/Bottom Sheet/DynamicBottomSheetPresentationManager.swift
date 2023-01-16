//
//  DynamicBottomSheetPresentationManager.swift
//  CoreUserInterface
//
//  Created by Ievgen Goloboiar on 10.07.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

/// `DynamicBottomSheetPresentationManager` class provides configurated `BottomSheetPresentationManager` instance for
/// a specific view and changes its size dynamically..
public final class DynamicBottomSheetPresentationManager: BottomSheetPresentationManager {

	// MARK: - Constants.

	public enum SnappingConstants {
		/// The value that the `containerTopConstraintToSafeArea` should have for the container to be considered hidden.
		public static let hiddenConstraintConstant: CGFloat = UIScreen.main.bounds.height
		
		/// Percentage of the distance that will be considered threshold.
		static let thresholdPercentage: CGFloat = 0.3
	}
		
	// MARK: - Private vars
		
	/// `UIView` object. Should be bottomSheetView or any another UIView.
	private unowned var _sheetContent: DynamicSheetContent
	
	/// `NSLayoutConstraint` object. Constraint to `SuperView.Top` or `SafeArea.Top`.
	private let constraintToTop: NSLayoutConstraint
	
	/// Used to compute the new value of the `constrantToTop` in accordance to the new `contentSize`.
	private let _viewHeight: CGFloat
	
	/// Maximum value that the bottom sheet can have in the context in which it is presented.
	private let _maxHeight: CGFloat
	
	/// Minimum value that the bottom sheet can have in the context in which it is presented.
	private let _minHeight: CGFloat

	// Keep refence to check while clearing other gesture recognizers.
	private lazy var _tapGestureRecognizer: UITapGestureRecognizer = {
		let gestureRecognizer: UITapGestureRecognizer = .init()
		gestureRecognizer.cancelsTouchesInView = false
		gestureRecognizer.addTarget( self, action: #selector(handleTapGesture) )
		return gestureRecognizer
	}()
	
	/// Fully expanded bottom sheet value. Minimum distance to top. The lower distnace to top is, the higher sheet we have.
	private let _fullyExpandedConstraintValue: CGFloat
	
	/// Expanded constrained value. Max distance to top.
	private let _collapsedConstraintValue: CGFloat
	
	/// Previous `contentSize` that we have registered from the size observation callback.
	private var previousContentSize: CGSize = .zero

	/// `contentSize` of the `_sheetContent`.
	private var _bottomSheetContentHeight: CGFloat {
		// Get contentSize of scrollView. Consider contentSize and content insets.
		return _sheetContent.contentSize.height
	}

	// MARK: - Initialization
	
	/// Initialize `DynamicBottomSheetPresentationManager` instance.
	///
	/// **Important!** If you have custom TopBarView which doesn't respect SafeArea and have autoresizing logic for iPhoneX, you should have SizingView as on the frontPage.
	/// Constraint `SizingView` to `.right`, `.left`, `.bottom` of `SafeArea` and `topBarView.bottom`.
	/// In this way we can take entire UIView height and calculte dynamic height regardless of any topBar elements.
	///
	/// - Parameters:
	///   - containerView: The view in which the `sheetContent` will be animated. Needed for performing the animation using `layoutIfNeeded()`.
	///   - constraintToTop: The constraint that will be used to animate the sheet's position.
	///   - sheetContent: The content that will reside in the `bottom sheet`.
	///   - viewHeight: The height of the view relative to which we should display the sheet.
	///   - topOffset: Offset relative to`viewHeight` that should be respected in order to determine the maximum height that the sheet can have.
	///   - minHeight: The minimum value that the bottom sheet should have in the `.partiallyDisplayed` state.
	public init?( containerView: UIView, constraintToTop: NSLayoutConstraint, sheetContent: DynamicSheetContent, viewHeight: CGFloat, topOffset: CGFloat = 0, minHeight: CGFloat ) {
		self.constraintToTop = constraintToTop
		_sheetContent = sheetContent
		_viewHeight = viewHeight
		_minHeight = minHeight
		_maxHeight = viewHeight - topOffset
		_fullyExpandedConstraintValue = topOffset
		_collapsedConstraintValue = viewHeight - minHeight

		let threshold: CGFloat = abs( _fullyExpandedConstraintValue - _collapsedConstraintValue ) * SnappingConstants.thresholdPercentage
		let hiddenConfiguration: SheetSnapConfiguration = SheetSnapConfiguration( constraintConstant: SnappingConstants.hiddenConstraintConstant, threshold: 0.0 )
		let partiallyDisplayedConfiguration: SheetSnapConfiguration = SheetSnapConfiguration( constraintConstant: _collapsedConstraintValue, threshold: threshold )
		let fullyDisplayedConfiguration: SheetSnapConfiguration = SheetSnapConfiguration( constraintConstant: _fullyExpandedConstraintValue, threshold: threshold )

		// Init the bottom sheet once and update its stateMapping afterwards.
		super.init(
			topContainerConstraint: constraintToTop,
			view: containerView,
			stateMapping: [.hidden: hiddenConfiguration, .partiallyDisplayed: partiallyDisplayedConfiguration, .fullyDisplayed: fullyDisplayedConfiguration],
			startingScrollViewContentOffset: .zero,
			startingState: .hidden )

		// Add the pan gesture so we can manually "expand" the sheet as well. Only if the _sheetContent is a view.
		addPanGestureRecognizer( to: sheetContent.viewToHandlePanGesture )

		// Observe content size changes.
		addContentSizeObserver()
		
		// Add toggling tap gesture recognizer.
		_sheetContent.addTogglingGesture( _tapGestureRecognizer )

		// Disable cancelTouchersInView for all gestures.
		// Othervise clicks on cells will be ignored.
		_sheetContent.disableCancelTouchesForAllGestures()
	}
	
	// MARK: - Public

	public override func animateSnapping( animationDuration: TimeInterval = Theme.Durations.standardAnimationDuration, completion: (() -> Void)? = nil ) {
		// Intercept the state change in order to let the delegate know of the change.
		if state == .partiallyDisplayed || state == .hidden {
			_sheetContent.sheetWillCollapse()
		} else if state == .fullyDisplayed {
			_sheetContent.sheetWillExpand()
		}

		super.animateSnapping( animationDuration: animationDuration, completion: completion )
	}

	// MARK: - Private

	/// Reacts to  `sheetContent` `contentSize` changes from and adjusts the snapping parameters of the `_bottomSheetManager`.
	private func updateBottomSheetSnappingParameters() {
		// Enable scrolling if we cannot fit all content in bottomSheet.
		enableScrollingIfNeededForExpandedHeight( _bottomSheetContentHeight )

		// Update the stateMapping since the size of the content has changed.
		update( stateMapping: computeStateMapping() )
	}

	/// Computes new `stateMapping` to be used in updating the `_bottomSheetManager.`
	private func computeStateMapping() -> [SheetState: SheetSnapConfiguration] {
		// For fully expanded state we should sum topBarHeight and topOffset. It will be distance to SuperView.Top.
		// The lower value we get, the heigher bottom sheet is.
		let fullyDisplayedTopConstraintConstant = computeFullyExpandedConstaintValue()

		// The heigher value we get the lower bottom sheet is.
		let partiallyDisplayedTopConstraintConstant = _viewHeight - _minHeight

		let threshold: CGFloat = abs( fullyDisplayedTopConstraintConstant - partiallyDisplayedTopConstraintConstant ) * SnappingConstants.thresholdPercentage

		let hiddenConfiguration: SheetSnapConfiguration = SheetSnapConfiguration( constraintConstant: SnappingConstants.hiddenConstraintConstant, threshold: 0.0 )
		let partiallyDisplayedConfiguration: SheetSnapConfiguration = SheetSnapConfiguration( constraintConstant: partiallyDisplayedTopConstraintConstant, threshold: threshold )
		let fullyDisplayedConfiguration: SheetSnapConfiguration = SheetSnapConfiguration( constraintConstant: fullyDisplayedTopConstraintConstant, threshold: threshold )
		return [.hidden: hiddenConfiguration, .partiallyDisplayed: partiallyDisplayedConfiguration, .fullyDisplayed: fullyDisplayedConfiguration]
	}

	/// Calculate value for fully expanded state depending on the current contentSize.
	/// - Returns: `CGFloat` value.
	private func computeFullyExpandedConstaintValue() -> CGFloat {
		if _bottomSheetContentHeight <= _maxHeight {
			// Sheet height is less than max height.
			// Subtract bottomSheet height and get value for constraintToSuperviewTop.
			// Make bottom sheet partially expanded.
			return _viewHeight - _bottomSheetContentHeight
		} else {
			// ContentSize is greater than sheet max height.
			//  Return minimum distance to top and get max sheet height. Make bottom sheet fully expanded.
			return _fullyExpandedConstraintValue
		}
	}

	/// Enable scrolling for full expanded height.
	/// - Parameter contentHeight: `CGFloat` value for full expanded height.
	private func enableScrollingIfNeededForExpandedHeight( _ contentHeight: CGFloat ) {
		// Consider contentHeight and distance from collectionView.Top and header.
		if contentHeight <= _maxHeight {
			// Sheet height is less than max height.
			// Disable scrolling since user can see all content.
			_sheetContent.isScrollEnabled = false
		} else {
			// ContentSize is greater than sheet max height.
			// Enable scrolling since user cannot see all content.
			_sheetContent.isScrollEnabled = true
		}
	}
	
	/// Adjust the snapping parameters based on the new `contentSize`, if any.
	private func addContentSizeObserver() {
		_sheetContent.addContentSizeChange { [weak self] newContentSize in
			guard self?.previousContentSize != newContentSize else { return }

			// Save new contentSize.
			self?.previousContentSize = newContentSize

			// Setup new bottomSheet manager.
			self?.updateBottomSheetSnappingParameters()
		}
	}
	
	// MARK: - Selectors
	
	@objc private func handleTapGesture() {
		// Toggle bottom sheet state on tap.
		snap()
	}
}
