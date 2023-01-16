//
//  SnackBarPresenter+Animator.swift
//  CoreUserInterface
//
//  Created by Olexandr Belozierov on 01.08.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit

extension SnackBarPresenter {
	
	/// Show/hide animator provider
	public struct Animator {
		
		public typealias Animator = (SnackBarPresenter, Bool) -> UIViewPropertyAnimator
		
		private let animator: Animator
		
		public init(animator: @escaping Animator) {
			self.animator = animator
		}
		
		func makeAnimator(for presenter: SnackBarPresenter, show: Bool) -> UIViewPropertyAnimator {
			animator(presenter, show)
		}
		
	}
	
}

public extension SnackBarPresenter.Animator {
	
	/// Animator for show/hide animation with fade effect.
	static var fade: Self {
		Self { presenter, show in
			UIViewPropertyAnimator(duration: CATransaction.animationDuration(), curve: .easeInOut) {
				presenter.snackBar.alpha = show ? 1 : 0
			}
		}
	}
	
	/// Animator for show/hide animation from the bottom of superview.
	static var fromBottom: Self {
		Self { presenter, show in
			UIViewPropertyAnimator(duration: CATransaction.animationDuration(), curve: .easeInOut) {
				guard let superview = presenter.snackBar.superview else { return }
				
				presenter.snackBar.transform = {
					if show { return .identity }

					var yOffset = presenter.snackBar.frame.height
					yOffset += superview.bounds.height - presenter.snackBar.frame.maxY

					return presenter.snackBar.transform.translatedBy(x: .zero, y: yOffset)
				}()
			}
		}
	}
	
}
