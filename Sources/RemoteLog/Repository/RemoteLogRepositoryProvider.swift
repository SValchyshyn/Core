//
//  RemoteLogRepositoryProvider.swift
//  RemoteLog
//
//  Created by Adrian Ilie on 06.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

public enum RemoteLogRepositoryError: Error {
	case storageFail
}

public protocol RemoteLogRepositoryProvider {
	/// Application name
	var snApplication: String { get set }
	
	typealias EntryIdentifier = String
	
	/// Schedule a log entry for transfer.
	///
	/// - parameter entry: log entry
	func scheduleForTransfer(_ entry: RemoteLogEntry) async throws
	
	/// Fetch a log entry available for transferring.
	/// Remember to call `markAsTransffered` or `markAsNotTransffered` on each log entry identifier according to result.
	///
	/// - returns: tuple containing log entry and it's identifier
	func fetchForTransfer() async throws -> (EntryIdentifier, RemoteLogEntry)?
	
	/// Mark a log entry as transferred succesfuly.
	///
	/// - parameter identifier: log entry's identifier
	func markAsTransffered(_ identifier: EntryIdentifier) async throws
	
	/// Mark a log entry as not transferred.
	///
	/// - parameter identifier: log entry's identifier
	func markAsNotTransffered(_ identifier: EntryIdentifier) async throws
}

struct RemoteLogEntriesProvider: AsyncSequence, AsyncIteratorProtocol {
	var repository: RemoteLogRepositoryProvider
	
	init(repository: RemoteLogRepositoryProvider) {
		self.repository = repository
	}
	
	func makeAsyncIterator() -> RemoteLogEntriesProvider {
		self
	}
	
	typealias Element = (RemoteLogRepositoryProvider.EntryIdentifier, RemoteLogEntry)

	mutating func next() async -> Element? {
		return try? await self.repository.fetchForTransfer()
	}
}
