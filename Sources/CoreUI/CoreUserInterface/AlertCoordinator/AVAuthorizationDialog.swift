//
//  AVAuthorizationDialog.swift
//  CoopUI
//
//  Created by Georgi Damyanov on 11/12/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import AVFoundation
import UIKit

/**
Container for enqueueing a AVCaptureDevice authorization dialog via the `AlertCoordinator`
*/
public struct AVAuthorizationDialog: AlertRepresenting {
	let type: AVMediaType
	let completion: (Bool) -> Void

	/// Explicit public initializer, since the default one is internal
	public init(type: AVMediaType, completion: @escaping (Bool) -> Void) {
		self.type = type
		self.completion = completion
	}

	public func present( overViewController: UIViewController, didDismiss: @escaping () -> Void ) {
		AVCaptureDevice.requestAccess( for: type) { granted in
			// Notify that we are done with the presentation
			didDismiss()
		
			// Call the completion
			self.completion( granted )
		}
	}
}

/**
We implement `Equatable` in order to ensure that the same dialog is not queued twice.
*/
extension AVAuthorizationDialog: Equatable {
	public static func == (lhs: AVAuthorizationDialog, rhs: AVAuthorizationDialog) -> Bool {
		return lhs.type == rhs.type
	}
}
