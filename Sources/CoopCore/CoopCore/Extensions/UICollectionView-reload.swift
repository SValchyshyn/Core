//
//  UICollectionView-reload.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 14/08/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

public extension UICollectionView {
	/// Reloads all of the data for the collection view and can force the cell layout.
	///
	/// Call this method sparingly when you need to reload all of the items in the collection view. This causes the collection view to discard any currently visible items (including placeholders) and recreate items based on the current state of the data source object. For efficiency, the collection view only displays those cells and supplementary views that are visible. If the collection data shrinks as a result of the reload, the collection view adjusts its scrolling offsets accordingly.
	/// You should not call this method in the middle of animation blocks where items are being inserted or deleted. Insertions and deletions automatically cause the collection’s data to be updated appropriately.
	/// - Parameter forceLayout: `true` will force the cell `layout` by calling `layoutIfNeeded`.
	func reloadData( forcingLayout: Bool ) {
		// Request a data reload.
		reloadData()

		// Force a layoutIfNeeded to prevent the cells to be laid out during the next
		// layout cycle and instantly instead.
		forcingLayout ? layoutIfNeeded() : ()
	}

	/// Reloads just the items at the specified index paths and can force the cell layout.
	///
	/// Call this method to selectively reload only the specified items. This causes the collection view to discard any cells associated with those items and redisplay them.
	/// - Parameters:
	///   - indexPaths: An array of NSIndexPath objects identifying the items you want to update.
	///   - forceLayout: `true` will force the cell `layout` by calling `layoutIfNeeded`.
	func reloadItems( at indexPaths: [IndexPath], forcingLayout: Bool ) {
		// Request a data reload.
		reloadItems( at: indexPaths )

		// Force a layoutIfNeeded to prevent the cells to be laid out during the next
		// layout cycle and instantly instead.
		forcingLayout ? layoutIfNeeded() : ()
	}
}
