//
//  WKWebView+ setKeyboardRequiresUserInteraction.swift
//  CoreUserInterface
//
//  Created by Nazariy Vlizlo on 26.11.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import WebKit

/// Helper class for automatically showing keyboard for `WKWebView`
class WebViewKeyboardAppearer {
	// Closure types for keyboard appearing selectors
	// @convention - annotate some function, in our case C function, because it has `c` parameter
	// More info at: https://docs.swift.org/swift-book/ReferenceManual/Attributes.html
	typealias OldClosureType =  @convention(c) ( Any, Selector, UnsafeRawPointer, Bool, Bool, Any? ) -> Void
	typealias NewClosureType =  @convention(c) ( Any, Selector, UnsafeRawPointer, Bool, Bool, Bool, Any? ) -> Void

	// Swizzling correct selector enum for keyboard appearing, depending on iOS version
	private enum ClosureType {
		case old
		case new

		/// Get correct selector depending on iOS version and
		var selectorUid: Selector {
			switch self {
			case .old:
				return sel_getUid( "_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:" )

			case .new:
				return sel_getUid( "_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:" )
			}
		}
	}

	// MARK: Private properties
	/// Value for storing original implementation of `WKContentView` method
	private var originalImplementation: IMP?

	/// Type for a closure for determine the right `selectorUid` and the right implementation, while performing swizzling
	private var closureType: ClosureType = .new

	/// WKContentView class from string, to use it later for getting methods instances
	private var WKContentView: AnyClass? {
		return NSClassFromString( "WKContentView" )
	}

	/// This method uses method swizzling, depending on iOS version to allow open keyboard without user interaction
	/// More information available at:
	/// https://stackoverflow.com/a/46029192/3542688
	/// - Parameter value: if you want to open keyboard without user interaction set it to false. Otherwise, set it to true.
	func setKeyboardRequiresUserInteraction( _ value: Bool ) {
		if #available( iOS 11.3, * ) {
			closureType = .new
		} else {
			closureType = .old
		}
		swizzle( value )
	}
	/// Resets the automatic keyboard appearance using the default implementation of `WKContentView` class
	func resetAutomaticKeyboardAppearance() {
		guard let WKContentView = WKContentView else {
			print( "keyboardDisplayRequiresUserAction extension: Cannot find the WKContentView class" )
			return
		}
		if let method = class_getInstanceMethod( WKContentView, closureType.selectorUid ), let originalImplementation = originalImplementation {
			method_setImplementation( method, originalImplementation )
		}
	}

	/// Function that use runtime method swizzling, to call correct implementation for showing/hiding a keyboard
	/// - Parameter value: value, used for showing/hiding a keyboard
	private func swizzle( _ value: Bool ) {
		guard let WKContentView = WKContentView else {
			print( "keyboardDisplayRequiresUserAction extension: Cannot find the WKContentView class" )
			return
		}

		switch closureType {
		case .old:
			if let method = class_getInstanceMethod( WKContentView, closureType.selectorUid ) {
				let originalImp: IMP = method_getImplementation( method )
				originalImplementation = originalImp
				let original: OldClosureType = unsafeBitCast( originalImp, to: OldClosureType.self )
				let block: @convention( block ) ( Any, UnsafeRawPointer, Bool, Bool, Any? ) -> Void = { me, arg0, _, arg2, arg3 in // swiftlint:disable:this identifier_name - Explcit enough. -FAIO
					original( me, self.closureType.selectorUid, arg0, !value, arg2, arg3 )
				}
				let imp: IMP = imp_implementationWithBlock( block )
				method_setImplementation( method, imp )
			}

		case .new:
			if let method = class_getInstanceMethod( WKContentView, closureType.selectorUid ) {
				let originalImp: IMP = method_getImplementation( method )
				originalImplementation = originalImp
				let original: NewClosureType = unsafeBitCast( originalImp, to: NewClosureType.self )
				let block: @convention( block ) ( Any, UnsafeRawPointer, Bool, Bool, Bool, Any? ) -> Void = { me, arg0, _, arg2, arg3, arg4 in // swiftlint:disable:this identifier_name - Explcit enough. -FAIO
					original( me, self.closureType.selectorUid, arg0, !value, arg2, arg3, arg4 )
				}
				let imp: IMP = imp_implementationWithBlock( block )
				method_setImplementation( method, imp )
			}
		}
	}

	deinit {
		resetAutomaticKeyboardAppearance()
	}
}
