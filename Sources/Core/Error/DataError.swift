//
//  DataError.swift
//  CoopM16
//
//  Created by Christian Sjøgreen on 16/08/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

/// Defines relevant errors for data retrieval tasks.
public enum DataError: Error {
	/// User credentials required.
	case notLoggedIn
	
	/// Server or data base is not accessible.
	case notFound
	
	/// Failed to fetch resource due to connectivity issues.
	case network
	
	/// The data received is in the wrong format.
	case invalidData
	
	/// The resource or element of the list is missing at the source
	case missing
	
	/// Captures all other types of errors that have not yet been specified.
	case other( Error )
}
