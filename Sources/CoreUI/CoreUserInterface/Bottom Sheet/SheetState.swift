//
//  SheetState.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 18.11.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// Defines the states in which the sheet can be found.
public enum SheetState: Int {

	/// Not visible on the screen at all.
	case hidden = 0

	/// Partially visible on the screen.
	case partiallyDisplayed

	/// Fully visible on the screen. Can't have a higher area than in this state.
	case fullyDisplayed
}
