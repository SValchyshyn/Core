//
//  FrontPageNavigationDelegate.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 03/01/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

/// Custom navigation delegate for animating the front page blobs.
public final class FrontPageNavigationDelegate: NSObject, UINavigationControllerDelegate {
	public func navigationController( _ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController ) -> UIViewControllerAnimatedTransitioning? {
		// Check if this is a push or pop operation
		switch operation {
		case .push:
			if let blobParams = (fromVC as? BlobExpansionDelegate)?.blobParameters {
				return BlobTransition( direction: .push, params: blobParams )
			} else {
				return ModalTransition( direction: .push )
			}

		case .pop:
			if let blobParams = (toVC as? BlobExpansionDelegate)?.blobParameters {
				return BlobTransition( direction: .pop, params: blobParams )
			} else {
				return ModalTransition( direction: .pop )
			}

		default:
			return nil
		}
	}
}
