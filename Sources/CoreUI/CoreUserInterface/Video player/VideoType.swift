//
//  VideoType.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 23.12.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import Foundation

enum VideoType {
	case mp4
	case html
	
	// MARK: Initialization
	init(urlString: String) {
		if urlString.contains(".mp3") || urlString.contains(".mp4") {
			self = .mp4
		} else {
			self = .html
		}
	}
}
