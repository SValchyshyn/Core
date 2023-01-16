//
//  BatchUpdates.swift
//  CoreUserInterface
//
//  Created by Olexandr Belozierov on 28.09.2021.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import DifferenceKit
import UIKit

/// Factory to create collection updates that can be applied to `UITableView`
public struct BatchUpdates {
	
	// MARK: - 	DifferenceKit
	
	/// Creates `BatchUpdates` that is based on `DifferenceKit`.
	public static func differenceKit<T: RangeReplaceableCollection>(source: T, target: T, dataUpdater: @escaping (T) -> Void) -> BatchUpdates where T.Element: Differentiable {
		let changes = DifferenceKitBasedChanges(source: source, target: target, dataUpdater: dataUpdater)
		return BatchUpdates(changes: changes)
	}
	
	// MARK: - 	By IndexPath
	
	/// Creates `BatchUpdates` with updates at indexPaths.
	public static func updateItems(at indexPaths: [IndexPath]) -> BatchUpdates {
		let changes = IndexPathBaseChanges(elementUpdated: indexPaths)
		return BatchUpdates(changes: changes)
	}
	
	/// Creates `BatchUpdates` with updates at indexes in some section.
	public static func updateItems(at indexes: [Int], in section: Int = .zero) -> BatchUpdates {
		updateItems(at: indexes.map { IndexPath(row: $0, section: section) })
	}
	
	fileprivate let changes: TableViewUpdatable
	
}

private protocol TableViewUpdatable {
	
	func applyChanges(to tableView: UITableView, with animation: UITableView.RowAnimation)
	
}

/// `DifferenceKit.StagedChangeset` wrapper.
private struct DifferenceKitBasedChanges<T: RangeReplaceableCollection>: TableViewUpdatable where T.Element: Differentiable {
	
	private let changeSet: StagedChangeset<T>
	private let dataUpdater: (T) -> Void
	
	init(source: T, target: T, dataUpdater: @escaping (T) -> Void) {
		changeSet = StagedChangeset(source: source, target: target)
		self.dataUpdater = dataUpdater
	}
	
	func applyChanges(to tableView: UITableView, with animation: UITableView.RowAnimation) {
		tableView.reload(using: changeSet, with: animation, setData: dataUpdater)
	}
	
}

/// Element changes based on indexPaths.
private struct IndexPathBaseChanges: TableViewUpdatable {
	
	let elementUpdated: [IndexPath]
	
	func applyChanges(to tableView: UITableView, with animation: UITableView.RowAnimation) {
		tableView.reloadRows(at: elementUpdated, with: animation)
	}
	
}

extension UITableView {
	
	/// Applies cell changes to tableView.
	public func applyBatchUpdates(_ batchUpdates: BatchUpdates, with animation: RowAnimation = .automatic) {
		batchUpdates.changes.applyChanges(to: self, with: animation)
	}
	
}
