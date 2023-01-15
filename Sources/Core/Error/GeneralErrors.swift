//
//  GeneralErrors.swift
//  CoopCore
//
//  Created by Coruț Fabrizio on 06/10/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

public enum GeneralErrors {
	/// Generic error displaying information that something has gone wrong with the server.
	public static let server: CoreBaseError = .init( titleKey: "error_generic_data_load_title", bodyKey: "error_generic_data_load_body" )
}
