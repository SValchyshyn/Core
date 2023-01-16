//
//  ReplaceViewControllerSegue.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 20/06/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import Core

public class ReplaceRootViewControllerSegue: UIStoryboardSegue {
	public struct Constants {
		/// Transistion animation duration
		public static let animationDuration: TimeInterval = 0.3

		/// How much the destination view controller's view is scaled initially
		static let scale: CGFloat = 1.2
	}
	
	public override func perform() {
		if let window = UIApplication.currentKeyWindow, let destinationSnapshot = destination.view.snapshotView(afterScreenUpdates: true) {
			destinationSnapshot.alpha = 0

			destinationSnapshot.transform = CGAffineTransform( scaleX: Constants.scale, y: Constants.scale )
			window.insertSubview( destinationSnapshot, aboveSubview: source.view)

			UIView.animate( withDuration: Constants.animationDuration, animations: {
				destinationSnapshot.alpha = 1
				destinationSnapshot.transform = CGAffineTransform.identity
			}, completion: { [destination, source] _ in
				if source.presentingViewController != nil {
					// Dismiss the safari controller, since it otherwise keeps a strong reference to the presenter
					source.dismiss( animated: false )
				}

				// Set new root view controller.
				window.rootViewController = destination
				destinationSnapshot.removeFromSuperview()
			})
		}
	}
}
