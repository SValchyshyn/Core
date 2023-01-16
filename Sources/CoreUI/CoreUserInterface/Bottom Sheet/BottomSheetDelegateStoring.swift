//
//  BottomSheetDelegateStoring.swift
//  CoreUserInterface
//
//  Created by Ihor Zabrotskyi on 03.12.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public protocol BottomSheetDelegateStoring: AnyObject {
	
	var sheetDelegate: BottomSheetDelegate? { get set }
}
