//
//  Log.swift
//  LogTests
//
//  Created by Adrian Ilie on 27.10.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import XCTest
import Combine
import Logging

@testable import Log

// swiftlint:disable private_over_fileprivate - makes sense to have multiple mocked data types with the same name in different files
// swiftlint:disable force_try_gp - no harm in tests

class TestLog: XCTestCase {
	func testMetadataStructure() {
		let expLogEntry = expectation(description: "Log entry received")
		let requestUrlString = "https://external.url/path/to/Method?some=getParams&other=params"
		let requestBodyString = "somePost=data&inThe=expectedFormat"
		var request = URLRequest(url: URL(string: requestUrlString)!)
		request.httpBody = requestBodyString.data(using: .utf8)
		
		let testLog = Logging.Logger(label: "test") { _ in
			return MockLogHandler { level, message, metadata in
				XCTAssertEqual(level, .trace)
				XCTAssertEqual(message, "log.message")
				
				XCTAssertEqual(metadata?[LogMetadataKey.identifier.rawValue], "log.identifier")
				
				guard case let .string(error) = metadata?[LogMetadataKey.error.rawValue] else {
					XCTFail("Missing error metadata")
					return
				}
				XCTAssertEqual(error, String(describing: MockError.example))
				
				guard case let .string(errorDescription) = metadata?[LogMetadataKey.errorDescription.rawValue] else {
					XCTFail("Missing error - description metadata")
					return
				}
				XCTAssertEqual(errorDescription, MockError.example.localizedDescription)
				
				guard case let .string(urlString) = metadata?[LogMetadataKey.requestUrl.rawValue] else {
					XCTFail("Missing request - url metadata")
					return
				}
				XCTAssertEqual(urlString, requestUrlString)
				
				guard case let .string(bodyString) = metadata?[LogMetadataKey.requestBody.rawValue] else {
					XCTFail("Missing request - body metadata")
					return
				}
				XCTAssertEqual(bodyString, requestBodyString)
				
				guard case let .string(receiptId) = metadata?[LogMetadataKey.receiptId.rawValue] else {
					XCTFail("Missing receiptId metadata")
					return
				}
				XCTAssertEqual(receiptId, "receipt.id")
				
				let decoder = JSONDecoder()
				
				guard case let .string(value) = metadata?["custom.bool"], let boolValue = value.data(using: .utf8) else {
					XCTFail("Missing custom metadata with Bool type")
					return
				}
				XCTAssertEqual(try! decoder.decode(Bool.self, from: boolValue), true)
				
				guard case let .string(value) = metadata?["custom.int"], let intValue = value.data(using: .utf8) else {
					XCTFail("Missing custom metadata with Int type")
					return
				}
				XCTAssertEqual(try! decoder.decode(Int.self, from: intValue), 0)
				
				guard case let .string(value) = metadata?["custom.float"], let floatValue = value.data(using: .utf8) else {
					XCTFail("Missing custom metadata with Float/Double type")
					return
				}
				XCTAssertEqual(try! decoder.decode(Decimal.self, from: floatValue), 3.012349)
				
				guard case let .string(value) = metadata?["custom.string"], let stringValue = value.data(using: .utf8) else {
					XCTFail("Missing custom metadata with String type")
					return
				}
				XCTAssertEqual(try! decoder.decode(String.self, from: stringValue), "custom.value")
				
				expLogEntry.fulfill()
			}
		}
		
		testLog.log(.trace, "log.message", [
			.identifier("log.identifier"),
			.error(MockError.example),
			.urlRequest(request),
			.receiptId("receipt.id"),
			.customBool(key: "custom.bool", value: true),
			.customInt(key: "custom.int", value: 0),
			.customFloat(key: "custom.float", value: 3.012349),
			.customString(key: "custom.string", value: "custom.value")
		])
		
		waitForExpectations(timeout: 3)
	}
}

fileprivate struct MockLogHandler: LogHandler {
	typealias LogClosure = (Logging.Logger.Level, Logging.Logger.Message, Logging.Logger.Metadata?) -> Void
	let logCallbackHandler: LogClosure
	
	// MARK: - LogHandler
	
	var logLevel: Logging.Logger.Level = .trace
	
	var metadata: Logging.Logger.Metadata = [:]
	
	subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
		get {
			return metadata[metadataKey]
		}
		set {
			metadata[metadataKey] = newValue
		}
	}
	
	// swiftlint:disable function_parameter_count - interface provided by Apple as-is
	func log(
		level: Logging.Logger.Level,
		message: Logging.Logger.Message,
		metadata: Logging.Logger.Metadata?,
		source: String,
		file: String,
		function: String,
		line: UInt
	) {
		logCallbackHandler(level, message, metadata)
	}
}

fileprivate enum MockError: Error {
	case example
}
