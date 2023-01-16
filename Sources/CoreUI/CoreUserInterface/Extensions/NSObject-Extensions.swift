//
//  NSObject-Extensions.swift
//  CoopCore
//
//  Created by Georgi Damyanov on 30/12/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import Log

@objc public extension NSObject {
	/**
	Swap the given selectors for the given class. This is utility function used for encapsulating the boilerplate plate code associated with method swizzling.
	*/
	static func exchangeSelectors( for cls: AnyClass?, originalSelector: Selector, swizzledSelector: Selector ) {
		// Extract methods from selectors
		guard let originalMethod = class_getInstanceMethod( cls, originalSelector ) else {
			Log.technical.log(.error, "Failed swizzling for original selector: \(originalSelector). Swizzled selector: \(swizzledSelector)", [.identifier("core.originalMethodSwizzleFailed")])
			return
		}

		guard let swizzledMethod = class_getInstanceMethod( cls, swizzledSelector ) else {
			Log.technical.log(.error, "Failed swizzling for original selector: \(originalSelector). Swizzled selector: \(swizzledSelector)", [.identifier("core.swizzleMethodFailed")])
			return
		}

		// Add or replace method
		let didAddMethod = class_addMethod( cls, originalSelector, method_getImplementation( swizzledMethod ), method_getTypeEncoding( swizzledMethod ))
		if didAddMethod {
			class_replaceMethod( cls, swizzledSelector, method_getImplementation( originalMethod ), method_getTypeEncoding( originalMethod ))
		} else {
			method_exchangeImplementations( originalMethod, swizzledMethod )
		}
	}
}
