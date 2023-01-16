//
//  ChainFilterViewModel.swift
//  StoresUI
//
//  Created by Coruț Fabrizio on 23.10.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import Foundation

open class ChainFilterViewModel {

	public enum SaveResult {
		/// The `currentFilter` filters out all the `Chains` that we have available to filter out of.
		/// At least one `Chain` should remain available for the user.
		case atLeastOneChainRequired
		
		/// The save of the `filter` has been successful.
		case success
		
		/// Could not save the new `filter` value.
		case failure( error: Error )
	}
	
	/// Default data source. Those are the chains that should always be available to filter upon.
	/// Array instead of `Set` since the order matters.
	public let dataSource: [Chain]

	/// Contains the currently filtered `Chain`. Used to gray-out the filtered-out ones.
	public private(set) var currentOutFilter: Set<Chain>
	
	/// Handles the storage of the `filter` that we're visually presenting and modifying right now.
	public let chainManager: ChainFilterManager
	
	/// The `Chains` that are selected, from the list of `dataSource`.
	public var selectedChains: [Chain] {
		dataSource.filter { !currentOutFilter.contains( $0 ) }
	}
	
	// MARK: - Init
	
	/// - Parameters:
	///   - filteredOutChains: List of `Chains` present in `ChainFilterManager.allChains` that should _not_ be visible in this filtering.
	///   - chainManager: Handles the storage of the `filter` that we're visually presenting and modifying right now.
	public init( filteredOutChains: Set<Chain> = .init(), chainManager: ChainFilterManager ) {
		// Set as data source only the chains that are allowed.
		self.dataSource = chainManager.allChains.filter { !filteredOutChains.contains( $0 ) }
		self.currentOutFilter = chainManager.getFilter()
		self.chainManager = chainManager
	}
	
	/// Saves to local storage the `currentFilter`.
	/// - Parameter completion: Called
	open func saveFilter( completion: @escaping (SaveResult) -> Void ) {
		// If all the Chains in the dataSource are found in the currentOutFilter,
		// then we have deselected all the currently available Chains. We should not allow this.
		if Set( dataSource ).isSubset( of: currentOutFilter ) {
			return completion( .atLeastOneChainRequired )
		}
		
		// Update the local filter.
		chainManager.set( filter: currentOutFilter )
		
		// Call the completion.
		completion( .success )
	}
	
	/// - Parameter chain: The `Chain` whose availability should be determined.
	/// - Returns: `true` if the `Chain` should be rendered as if it's filtered in.
	open func isChainEnabled( _ chain: Chain ) -> Bool {
		// The filter is an _out_ filter, meaning that the filter will contain the values that are _not_ selected
		!currentOutFilter.contains( chain )
	}
	
	/// Called when the `Chain cell` is tapped
	/// - Parameter chain: Used to determine if we're going to select/ deselect it.
	open func interact( with chain: Chain ) {
		// Remove the chain from the set if it already contains it, otherwise remove it.
		currentOutFilter = currentOutFilter.symmetricDifference( [chain] )
	}
	
	/// Called from `didSelectItemAt:indexPath:` delegate method in order to determine if the item is
	/// selectable or not.
	/// - Parameter chain: The `Chain`
	open func shouldInteract( with chain: Chain ) -> Bool {
		true
	}
}
