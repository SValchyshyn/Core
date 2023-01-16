//
//  CheckmarkSpinnerAnimationView.swift
//  CoopM16
//
//  Created by Frederik Sørensen on 16/01/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit
import Lottie

public class CheckmarkSpinnerAnimationView: UIView {
	private let animationView: AnimationView = {
		let animationView = AnimationView( animation: animationsContent.loadingAnimation )
		animationView.translatesAutoresizingMaskIntoConstraints = false
		animationView.contentMode = .scaleAspectFit
		animationView.loopMode = .loop
		animationView.isHidden = true
		return animationView
	}()

	override public func layoutSubviews() {
		super.layoutSubviews()

		// Only do this once
		guard animationView.superview == nil else { return }

		addSubview( animationView )
		animationView.pinEdges( to: self )
	}

	// MARK: - Public functions

	/// Resume the current animation
	public func resumeAnimation() {
		if !animationView.isAnimationPlaying && animationView.superview != nil {
			// We are animating the checkmark
			animationView.play()
		}
	}

	// MARK: - Spinner animation

	/// Starts the spinner animation
	public func startSpinnerAnimation() {
		animationView.isHidden = false
		animationView.play()
	}

	/// Stops the spinner animation
	public func stopSpinnerAnimation() {
		animationView.isHidden = true
		animationView.stop()
	}

	// MARK: - Checkmark animation

	/// Starts the checkmark animtion
	public func startCheckmarkAnimation() {
		// Switch the animation and stop looping
		animationView.animation = animationsContent.successAnimation
		animationView.isHidden = false
		animationView.loopMode = .playOnce
		animationView.play()
	}
}
