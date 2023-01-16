//
//  LayoutProtocol.swift
//  CoreUserInterface
//
//  Created by Adrian Ilie on 22.11.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public protocol LayoutProtocol {
	/// Corner radius for buttons
	var buttonCornerRadius: CGFloat { get }
	
	/// Corner radius for smaller buttons
	var buttonSmallCornerRadius: CGFloat { get }
	
	/// Button border width
	var buttonBorderWidth: CGFloat { get }
	
	/// Feed cell button corner radius
	var feedCellButtonCornerRadius: CGFloat { get }
}
