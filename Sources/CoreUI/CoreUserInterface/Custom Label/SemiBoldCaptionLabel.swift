//
//  SemiBoldCaptionLabel.swift
//  CoreUserInterface
//
//  Created by Stepan Valchyshyn on 24.03.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

public class SemiBoldCaptionLabel: CustomLabel {
	public override func customInit() {
		super.customInit()
		font = fontProvider[.semibold( .caption )]
	}
}
