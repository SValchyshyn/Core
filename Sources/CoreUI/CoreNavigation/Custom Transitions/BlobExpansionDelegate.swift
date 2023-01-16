//
//  BlobExpansionDelegate.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 31/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

public protocol BlobExpansionDelegate: AnyObject {
	/// Used to create the transition animation.
	var blobParameters: BlobTransitionParameters? { get set }
}
