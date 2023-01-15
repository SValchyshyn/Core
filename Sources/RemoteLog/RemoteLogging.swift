//
//  RemoteLogging.swift
//  RemoteLog
//
//  Created by Adrian Ilie on 02.06.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

/**
Wrapper for old RemoteLog public interface.
*/
public class RemoteLogging {
	public static let shared = RemoteLogging()
	private init() { }
	
	private let log = RemoteLog.shared
	
	public var uploadService: RemoteLogUploadServiceProvider? {
		get {
			log.uploadService
		}
		set {
			log.uploadService = newValue
		}
	}
	
	public func start(snApplication: String) {
		log.start(snApplication: snApplication)
	}
	
	public func stop() {
		log.stop()
	}
}
