//
//  BottomSheetSupporting.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 18.11.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

public protocol BottomSheetSupporting {

	/// Called when the minimum height of the bottom sheet is determined and the content should be adjusted
	/// so it's aware of the presence of the bottom.
	/// - Parameter bottomSheetMinHeight: Height that the bottom sheet has while in the `collapsed` state.
	func adjustContent( for bottomSheetMinHeight: CGFloat )
}
