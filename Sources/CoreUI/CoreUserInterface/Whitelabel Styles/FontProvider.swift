//
//  FontProvider.swift
//  CoreUserInterface
//
//  Created by Nazariy Vlizlo on 24.07.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

/// Generic interface used to provide a way to define different font types, styles, customizations.
public protocol FontStyle: Hashable { }

/// Generic interface for providing app specific font customizations based on `FontStyle`.
public typealias FontProvider<Style: FontStyle> = ThemeContainer<Style, UIFont>
