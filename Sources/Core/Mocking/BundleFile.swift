//
//  BundleFile.swift
//  CoopM16
//
//  Created by Christian Sjøgreen on 18/09/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

/// Defines a file in the apps main bundle.
public struct BundleFile: Hashable {
	/// Resource file name.
	let name: String
	
	/// Resource file extension.
	let ext: String

	public init( name: String, ext: String ) {
		self.name = name
		self.ext = ext
	}
}

extension BundleFile: MockedResponseBody {
	/// Attempt to read file content from main Bundle.
	public var bodyData: Data? {
		guard let fileURL = Bundle.main.url( forResource: name, withExtension: ext ) else {
			print( "File not found in main Bundle: \(self)" )
			return nil
		}
		guard let content = try? Data( contentsOf: fileURL ) else {
			print( "Failed to parse content of file from main Bundle: \(self)" )
			return nil
		}
		return content
	}
}
