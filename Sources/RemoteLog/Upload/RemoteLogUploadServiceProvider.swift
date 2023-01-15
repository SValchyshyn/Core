//
//  RemoteLogUploadServiceProvider.swift
//  RemoteLog
//
//  Created by Adrian Ilie on 06.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public protocol RemoteLogUploadServiceProvider {
	/// Send log entry to remote server.
	///
	/// - parameter entry: log entry
	func upload(_ entry: RemoteLogEntry) async throws
}
