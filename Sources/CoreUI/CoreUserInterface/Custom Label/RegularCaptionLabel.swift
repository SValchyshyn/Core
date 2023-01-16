//
//  RegularCaptionLabel.swift
//  CoopM16
//
//  Created by Peter Antonsen on 21/05/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

public class RegularCaptionLabel: CustomLabel {
	public override func customInit() {
		super.customInit()
		font = fontProvider[.regular( .caption )]
	}
}
