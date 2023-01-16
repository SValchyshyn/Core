//
//  MonthSectionViewControllers.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 06/03/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit
import Core
import Log

/**
View controller intended for subclassing by view controllers which show their data grouped by months
*/
open class MonthSectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	// Just for readability and understanding.
	public typealias MonthDifference = Int

	struct Constants {
		/// The section header height for an empty section.
		static let emptySectionHeaderHeight: CGFloat = 85.0

		/// The section header height for a normal section.
		static let normalSectionHeaderHeight: CGFloat = 70.0

		static let monthsInAYear = 12
	}

	private let currentDateComponents = Calendar.current.dateComponents( [.month, .year], from: Date() )
	private var headerTitles: [MonthDifference: String] = [:]
	
	public var currentMonthIndex: MonthDifference = 0
	public var recordsDictionary: [MonthDifference: [DateGroupable]] = [:]

	/// Text for the empty sections, should be overriden in subclass.
	open var emptySectionTitle: String {
		return ""
	}

	// MARK: - Outlets

	@IBOutlet public weak var tableView: UITableView!

	// MARK: - View

	override open func viewDidLoad() {
		// Register the header view in order to reuse it.
		tableView.register( MonthSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: MonthSectionHeaderView.reuseIdentifier )
		
		tableView.estimatedSectionHeaderHeight = Constants.normalSectionHeaderHeight
	}

	// MARK: - UITableViewDataSource / UITableViewDelegate

	open func numberOfSections( in tableView: UITableView) -> Int {
		return currentMonthIndex
	}

	open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MonthSectionHeaderView.reuseIdentifier) as? MonthSectionHeaderView {
			headerView.monthAndYearLabel.text = headerTitles[section]

			// Set text of noReceiptsLabel to nil in order for the UILabel to occupy no space.
			if let count = recordsDictionary[section]?.count, count != 0 {
				headerView.noReceiptsLabel.isHidden = true
			} else {
				headerView.noReceiptsLabel.isHidden = false
				headerView.noReceiptsLabel.text = emptySectionTitle
			}

			return headerView
		}

		// If we can't display our section header, don't display anything.
		return nil
	}

	open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if let count = recordsDictionary[section]?.count, count == 0 {
			return Constants.emptySectionHeaderHeight
		}

		return UITableView.automaticDimension
	}

	open func tableView( _ tableView: UITableView, heightForFooterInSection section: Int ) -> CGFloat {
		// Removes footers in a grouped tableview
		return 0.01
	}

	// Each row is associated with a receipt in 'receipts'
	open func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
		return recordsDictionary[section]?.count ?? 0
	}

	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		assertionFailure( "Cell for row must be overriden in a subclass")
		return UITableViewCell()
	}

	// MARK: Utility functions

	/// Creates and groups the records based on the month and year of the group by date.
	public func process( groupableRecords records: [DateGroupable] ) {
		guard let currentMonth = currentDateComponents.month, let currentYear = currentDateComponents.year else {
			Log.technical.log(.error, "Something went wrong with the creating the current DateComponents.", [.identifier("CoopUI.MonthSectionViewController.process")])
			return
		}

		for record in records {
			let dateComponents = Calendar.current.dateComponents( [.month, .year], from: record.groupByDate )
			guard let receiptMonth = dateComponents.month, let receiptYear = dateComponents.year else {
				Log.technical.log(.error, "Something went wrong with the creating the receipt DateComponents.", [.identifier("CoopUI.MonthSectionViewController.process")])
				continue
			}

			// In order to see how far the receipt is from the _currentMonthIndex we have to do a manual calculation
			// Calendar.current.dateComponents(, from: , to: ) won't return the mathematical difference between 2 dates, it will return
			// by the calendar difference. So let's say we want the difference between 26 June and 7 July.
			// We need the month component to return a month difference of 1 (July = 7, June = 6, 7 - 6 = 1); but the method will return 0, because there is not a full month between the dates.
			let newMonthIndex: Int
			if receiptYear != currentYear {
				let monthsFromYearDifference = (currentYear - receiptYear) * Constants.monthsInAYear
				newMonthIndex = monthsFromYearDifference + currentMonth - receiptMonth
			} else {
				newMonthIndex = currentMonth - receiptMonth
			}

			// We are grouping the receipts in a Dictionary based on an index which represents the difference of months between the current date and the receipt date.
			// So receiptsGroups[1] will contain the receipts which are 1 month apart from the current date. receiptsGroups[2] will be from 2 months apart and so on.
			// _currentMonthIndex - represents the number of months between the current date and a date in the past through which we have to iterate.
			// It will start at 0 and will increment at every receipt date based on the month difference between them.
			// newMonthIndex - is the number of monthds between the current date and the receipt purchase date.
			// We have to iterate between the 2 variables in order to complete with the missing months because we have to add headers for months in which there was no receipt.
			while currentMonthIndex <= newMonthIndex {
				// Allocate the new array of receipts and prevent ovveriding.
				if recordsDictionary[currentMonthIndex] == nil {
					recordsDictionary[currentMonthIndex] = type( of: records ).init()
				}

				// Create the date for the missing month by substracting the number of months that the index got to.
				var newDateComponents = DateComponents()
				newDateComponents.month = -currentMonthIndex
				guard let newDate = Calendar.current.date( byAdding: newDateComponents, to: Date() ) else {
					Log.technical.log(.notice, "Something went wrong with the creating the new Date with _currentMonthIndex.", [.identifier("CoopUI.MonthSectionViewController.process")])
					continue
				}

				// Store the header title also.
				headerTitles[currentMonthIndex] = DateFormatter.fullMonthYearFormatter.string( from: newDate ).stringWithCapitalizedFirstLetter()
				currentMonthIndex += 1
			}

			// Append the new receipt.
			recordsDictionary[newMonthIndex]?.append( record )
		}
	}
}
