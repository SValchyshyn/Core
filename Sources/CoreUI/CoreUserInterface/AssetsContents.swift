//
//  AssetsContents.swift
//  CoreUserInterface
//
//  Created by Ihor Zabrotskyi on 04.10.2021.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import UIKit

/// Protocol for custom images' providers for Core components.
/// Returning `nil` for property means that default image will be used.
public protocol CoreAssetsCustomContents {
	var lightCloseImage: UIImage? { get }
	var darkCloseImage: UIImage? { get }
}
