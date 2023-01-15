//
//  GeneralURLHandler.swift
//  CoreNetworking
//
//  Created by Andriy Tkach on 8/22/22.
//  Copyright © 2022 Lobyco. All rights reserved.
//

public protocol GeneralURLHandler {
	
	/// Perform additional handling of network errors.
	/// - Parameter error: Error to handle.
	func handle(error: Error)
	
}
