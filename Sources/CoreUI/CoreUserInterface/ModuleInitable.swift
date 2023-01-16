//
//  ModuleInitable.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 07/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

public protocol ModuleInitable {
	/**
	Since some `.xibs` are declared in different modules, in order to instantiate them, we must specify the `Bundle` in which
	that `.xib` is defined otherwise it will default to the `.main Bundle` which will result in a crash.

	- returns:			An instance of the object using the bundle in which the specified object is declared.
	*/
	static func fromBundleXib() -> Self
}

extension UIViewController: ModuleInitable {
	public static func fromBundleXib() -> Self {
		return self.init( nibName: String( describing: Self.self ), bundle: Bundle( for: Self.self ) )
	}
}
