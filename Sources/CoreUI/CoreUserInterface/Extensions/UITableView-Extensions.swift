//
//  UITableView-Extensions.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 27.04.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import UIKit

public extension UITableView {

	/// Adapts the height of the `tableFooterView` to fill up the remaining space between the `contentSize` and the `frame.height`.
	/// This is useful when you want the content of the footer stick to the bottom of the `tableView` when the `contentSize` is less than the `frame.height`
	/// but also be placed after the whole content when the `contentSize` is greater than the `frame.height`.
	/// - Parameters:
	///   - minHeight: The `minimum` height that the `footer` should have for the situations in which it should not fill the space.
	///   - shouldDisableScrolling: `true` if we should disable scrolling if `contentSize.height <= frame.height`.
	func adjustFooterViewHeightToFillTableView( minHeight: CGFloat, shouldDisableScrolling: Bool ) {
		tableFooterView.map {
			// Force a layout so we get the true size of the cells, not just the estimates.
			layoutIfNeeded()

			// We want to see if there is any left space between the footer and the content.
			let currentFooterHeight = $0.frame.height
			// Subtract the currentFooterHeight because we want to compute the new height.
			let fitHeight = frame.height - contentInset.top - contentSize.height + currentFooterHeight

			// If there is, we should use that as the new header height instead of the minHeight
			let newHeight = fitHeight > minHeight ? fitHeight : minHeight

			// Reflect the frame changes.
			var newFrame = $0.frame
			newFrame.size.height = newHeight
			$0.frame = newFrame
			self.tableFooterView = $0

			// Check whether the tableView should scroll or not.
			// Make sure that tableView.layoutIfNeeded() is called so that the correct sizes are used.
			if shouldDisableScrolling {
				isScrollEnabled = contentSize.height > frame.height
			}
		}
	}

	/// Resizes the table footer to a size that is as close to the `targetHeight` as possible. This method should be called in `viewDidLayoutSubviews`.
	/// This method makes sure not to create an infinite loop of re-layout, so it is safe to call unconditionally.
	/// - Parameter targetHeight: The height that the table footer should aim for. Defaults to `UIView.layoutFittingCompressedSize.height` (the minimal size that fits the constraints)
	func resizeTableFooterView( targetHeight: CGFloat = UIView.layoutFittingCompressedSize.height ) {
		// Make sure that we have a footer to resize
		guard let footer = tableFooterView,
			  let size = computeNewFittingSize( for: footer, targetHeight: targetHeight ) else { return }

		// Modify the frame and re-assign to "apply" the changes.
		footer.frame.size.height = size.height
		tableFooterView = footer
	}

	/// Resizes the table header to a size that is as close to the `targetHeight` as possible. This method should be called in `viewDidLayoutSubviews`.
	/// This method makes sure not to create an infinite loop of re-layout, so it is safe to call unconditionally.
	/// - Parameter targetHeight: The height that the table header should aim for. Defaults to `UIView.layoutFittingCompressedSize.height` (the minimal size that fits the constraints)
	func resizeTableHeaderView( targetHeight: CGFloat = UIView.layoutFittingCompressedSize.height ) {
		// Make sure that we have a header to resize
		guard let header = tableHeaderView,
			  let size = computeNewFittingSize( for: header, targetHeight: targetHeight ) else { return }

		// Modify the frame and re-assign to "apply" the changes.
		header.frame.size.height = size.height
		tableHeaderView = header
	}

	/// Computes the best size which the `view` can have so that its internal constraints, `compression` and `hugging` priorities are fully satisfied.
	/// The `width` will be constrained to `frame.width`.
	/// - Parameters:
	///   - view: The view whose size we're computing.
	///   - targetHeight: The `minimum` value of the returned size`height`.
	/// - Returns: `nil` if the computed size's height is equal to the current height. The `width` comparison is not performed because we know that the
	/// width is always `frame.width`.
	private func computeNewFittingSize( for view: UIView, targetHeight: CGFloat ) -> CGSize? {
		// We get the closest size to `targetSize` that fits the constraints
		let size = view.systemLayoutSizeFitting( .init( width: frame.width, height: targetHeight ), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel )

		// When editing the height of the header, the view will trigger a re-layout - so we must check if the height is "out of sync" in order to avoid an infinite loop
		return view.frame.size.height != size.height ? size : nil
	}
}
