//
//  AnimatableContextProvider.swift
//  CoreUserInterface
//
//  Created by Ihor Zabrotskyi on 02.12.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

/// Interface for providing the graphics context for animating
public protocol AnimatableContextProvider: AnyObject {
	
	var graphicsContextView: UIView { get }
}
