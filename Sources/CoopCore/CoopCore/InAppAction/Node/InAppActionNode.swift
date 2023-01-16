//
//  InAppActionNode.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 18.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

/// Interface for vertices in graph for finding in-app action executor.
public protocol InAppActionNode: InAppActionable2 {
	
	/// Link to destination node and transition to it from source node
	typealias Link = (destination: InAppActionNode, transition: InAppActionExecutor?)
	
	/// Identifier for node. Should be unique.
	var identifier: AnyHashable { get }

	/// Transition to parent node
	var parentLink: Link? { get }
	
	/// Transitions to children nodes
	var childrenLinks: [Link] { get }
	
}

extension InAppActionNode where Self: Hashable {
	
	public var identifier: AnyHashable { self }
	
}

extension InAppActionNode where Self: AnyObject {
	
	public var identifier: AnyHashable { ObjectIdentifier(self) }
	
}
