//
//  SecurityLevel.swift
//  CoopCore
//
//  Created by Jens Willy Johannsen on 10/09/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

/**
Enum specifying the security level of the token to be retrieved.
*/
public enum SecurityLevel {
	/// Low security tokens expire every 12 months
	case lowSecurity

	/// High security tokens expire every 60 minutes and allow change PIN and payment card operations. High security operations are: change PIN and add/edit/remove payment card.
	case highSecurity
}
