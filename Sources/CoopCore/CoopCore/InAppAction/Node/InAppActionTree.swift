//
//  InAppActionTree.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 31.07.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

/// Create graph (tree) of `InAppActionNode`s. Is used for finding `InAppActionExecutor` in tree.
public struct InAppActionTree {
	
	/// Start node to perform search in tree.
	public let rootNode: InAppActionNode
	
	public init(rootNode: InAppActionNode) {
		self.rootNode = rootNode
	}
	
}

extension InAppActionTree: InAppActionable2 {
	
	private enum Visit {
		case source, link(source: InAppActionNode, transition: InAppActionExecutor?)
	}
	
	/// Find in-app executor for action in graph. Based on depth-first search algorithm.
	public func inAppActionExecutor(for action: InAppAction2) -> InAppActionExecutor? {
		var visited = [rootNode.identifier: Visit.source]
		var stack: [InAppActionNode] = [rootNode]
		
		func shouldGoToLink(_ link: InAppActionNode.Link, from source: InAppActionNode) -> Bool {
			guard visited[link.destination.identifier] == nil else { return false }
			
			visited[link.destination.identifier] = .link(source: source, transition: link.transition)
			stack.append(link.destination)
			
			return true
		}
		
		outer: while var node = stack.last {
			
			// First go to children nodes
			for child in node.childrenLinks where shouldGoToLink(child, from: node) {
				continue outer
			}
			
			// Then ask node's `inAppActionExecutor`
			if let executor = node.inAppActionExecutor(for: action) {
				var path = [InAppActionNode.Link]()
				
				// Form path to `node` executor
				while case let .link(source, transition) = visited[node.identifier] {
					path.insert((node, transition), at: 0)
					node = source
				}
				
				// Create executor from path and node executor
				return InAppActionGroupExecutor(executors: path.compactMap { $0.transition } + [executor])
			}
			
			// Go to parent note
			if let parent = node.parentLink, shouldGoToLink(parent, from: node) {
				continue
			}
			
			stack.removeLast()
		}
		
		return nil
	}
	
}
