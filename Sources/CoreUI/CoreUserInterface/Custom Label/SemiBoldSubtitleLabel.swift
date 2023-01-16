//
//  SemiBoldSubtitleLabel.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 16/05/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

public class SemiBoldSubtitleLabel: CustomLabel {
	public override func customInit() {
		super.customInit()
		font = fontProvider[.semibold(.subtitle)]
	}
}
