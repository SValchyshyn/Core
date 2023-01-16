//
//  ReceiptHeaderView.swift
//  CoopM16
//
//  Created by Coruț Fabrizio on 07/08/2018.
//  Copyright © 2018 Greener Pastures. All rights reserved.
//

import UIKit

public class MonthSectionHeaderView: UITableViewHeaderFooterView {
	@IBOutlet weak var monthAndYearLabel: UILabel!
	@IBOutlet weak var noReceiptsLabel: UILabel!
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		setupView()
	}
	
	private func setupView() {
		monthAndYearLabel.font = fontProvider.H6HeaderFont
		monthAndYearLabel.textColor = colorsContent.bodyTextColor
		
		noReceiptsLabel.font = fontProvider[.regular(.body)]
		noReceiptsLabel.textColor = UIColor.black
	}
}
