//
//  LogMetadataProvider.swift
//  Log
//
//  Created by Adrian Ilie on 10.11.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public protocol LogMetadataProvider: AnyObject {
	/// Custom logging metadata provided
	var metadata: [LogMetadata]? { get }
}
