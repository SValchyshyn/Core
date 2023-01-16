//
//  InAppAction.swift
//  CoopUI
//
//  Created by Olexandr Belozierov on 13.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

/// Protocol to mark types as in-app actions.
/// `InAppAction2` is temporary name, should be renamed when old `InAppAction` will be removed.
public protocol InAppAction2 {
	
	/// Used to check equivalence
	var identifier: AnyHashable { get }
	
}

extension InAppAction2 {
	
	/// Default implementation for `identifier`. It is suitable for most cases. Can be overriden if needed.
	public var identifier: AnyHashable {
		"\(type(of: self)).\(self)"
	}
	
}

extension InAppAction2 where Self: Hashable {
	
	/// Default implementation for hashable ` InAppAction2`
	public var identifier: AnyHashable { self }
	
}
