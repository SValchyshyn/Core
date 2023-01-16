//
//  TableManager.swift
//  CoopM16
//
//  Created by Roxana-Madalina Sturzu on 18/11/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

/// Used to generalize the way we configure `UITableViewCells`.
public protocol GeneralTableViewCell: UITableViewCell {
	associatedtype Model

	/**
	Configures the cell.

	- parameter model:			Contains all the information needed to configure the cell.
	- parameter indexPath:		The `IndexPath` at which the cell is found.
	*/
	func configure( with model: Model, indexPath: IndexPath )
}

/// Used to communicate tap events on the `UITableViewCells`.
public protocol TableManagerDelegate: AnyObject {
	/**
	Called from `func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath )`.

	- parameter cell:			The selected cell.
	- parameter model:			The model used to configure the cell.
	*/
	func didSelect( cell: UITableViewCell?, with model: Any )
}

open class TableManager<Cell: GeneralTableViewCell>: NSObject, UITableViewDelegate, UITableViewDataSource {
	// MARK: - Properties.

	/// Where the cells will be laid out.
	public let tableView: UITableView

	/// The information used to configure the cells and populate the `collectionView`.
	public var dataSource: [Cell.Model]

	/// Used to signal tap events on the cells.
	public weak var delegate: TableManagerDelegate?

	// MARK: - Init.

	public init( _ tableView: UITableView ) {
		self.tableView = tableView
		self.tableView.register( Cell.self )
		self.dataSource = []

		super.init()

		// Listen to delegate calls that we implemented.
		self.tableView.delegate = self
		self.tableView.dataSource = self
	}
	
	public func reload() {
		tableView.reloadData()
	}

	// MARK: - UITableViewDataSource method implementation.

	open func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
		return dataSource.count
	}

	open func numberOfSections( in tableView: UITableView ) -> Int {
		return 1
	}

	open func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
		// Dequeue.
		let cell = tableView.dequeue( Cell.self, for: indexPath )

		// Configure.
		cell.configure( with: dataSource[indexPath.row], indexPath: indexPath )

		// Return.
		return cell
	}

	// MARK: - UITableViewDelegate method implementation.

	open func tableView( _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath ) { }

	open func tableView( _ tableView: UITableView, heightForRowAt indexPath: IndexPath ) -> CGFloat {
		return UITableView.automaticDimension
	}

	open func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
		// Notify the delegate that a cell has been tapped.
		delegate?.didSelect( cell: tableView.cellForRow( at: indexPath ), with: dataSource[indexPath.item] )
	}
}
