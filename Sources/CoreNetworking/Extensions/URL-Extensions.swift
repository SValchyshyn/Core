//
//  URL-Extensions.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 14.12.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public extension URL {

	/// Attempts to create a `URL` from the `urlString`. `Special character encoding` attempt is performed if the a `URL` cannot be created from the initial string.
	/// - Parameter urlString: The `String` that represents the `URL` which might or might `not` have special characters escaped.
	init?( possiblyNonEscapedString urlString: String ) {
		if let url = Self( string: urlString ) {
			self = url
		} else if let encodedURL = urlString.addingPercentEncoding( withAllowedCharacters: .urlFragmentAllowed ),
				  let url = Self( string: encodedURL ) {
			self = url
		} else {
			return nil
		}
	}

	/// Indicates whether the URL has the `http` or `https` schemas.
	var isHttpUrl: Bool {
		return scheme?.lowercased() == "http" || scheme?.lowercased() == "https"
	}
}
