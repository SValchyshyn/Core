//
//  BannerViewDelegate.swift
//  CoopM16
//
//  Created by Jens Willy Johannsen on 25/08/2016.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import Core

public protocol BannerViewDelegate: AnyObject {
	func bannerAction()
}

// OK to use s global variable, since showRemoteDataAvailablePopup/hideRemoteDataAvailablePopup is always called from the main-thread and there will always only be _one_ instance of the new data banner visible.
private struct Global {
	// Note: this is a _weak_ var so it will be released if the owning view controller releases its view. In other words, it is not necessary to manually remove the banner view when the view controller unloads its views.
	static weak var banner: UIView?
}

// We have to define the constants here, since struct can't be defined internally in protocol extension.
private struct Constants {
	/// Scale when the banner is at it's smallest size 
	static let smallScale: CGFloat = 0.4
	
	/// Scale when the banner is at it's largest size
	static let largeScale: CGFloat = 1.1
}

public extension BannerViewDelegate where Self: UIViewController {

	/**
	Show a banner indicating that new data is available. This function is wrapper for `showBanner`.

	- parameter animated:	Flag indicating if the showing is animated
	- parameter view:		The view to which the banner is added
	- parameter offset:		The vertical offset of the banner from the top of the view
	*/
	func showNewDataAvailableBanner( animated: Bool, view: UIView, offset: CGFloat ) {
		showBanner( with: CoreLocalizedString( "gen_new_data_available" ), animated: animated, containerView: view, offset: offset )
	}

	/**
	Show the banner with the given parameters.

	- parameter title:		String to be shown in the banner.
	- parameter animated:	Flag indicating if the showing is animated.
	*/
	func createBanner( with title: String, animated: Bool ) -> UIView {
		// Instantiate view and set origin
		let bannerView = SimpleBannerView( with: title )
		bannerView.delegate = self

		if animated {
			// Create a opacity and a transform (scale) animation and group them (so they run in sync)
			let transformAnimation = CAKeyframeAnimation( keyPath: "transform" )
			transformAnimation.values = [ NSValue( caTransform3D: CATransform3DMakeScale( Constants.smallScale, Constants.smallScale, 1 )), NSValue( caTransform3D: CATransform3DMakeScale( Constants.largeScale, Constants.largeScale, 1 )), NSValue( caTransform3D: CATransform3DMakeScale( 1, 1, 1 )) ]
			transformAnimation.keyTimes = [ 0, 0.8, 1.0 ]

			let opacityAnimation = CAKeyframeAnimation( keyPath: "opacity" )
			opacityAnimation.values = [ 0, 1 ]
			opacityAnimation.keyTimes = [ 0, 1.0 ]

			let animationGroup = CAAnimationGroup()
			animationGroup.animations = [opacityAnimation, transformAnimation]
			animationGroup.duration = Theme.Durations.standardAnimationDuration
			animationGroup.isRemovedOnCompletion = true
			animationGroup.timingFunction = CAMediaTimingFunction( name: CAMediaTimingFunctionName.easeInEaseOut )

			bannerView.layer.add( animationGroup, forKey: "anim" )
		}

		return bannerView
	}

	/**
	Show the banner with the given parameters.
	
	- parameter title:				String to be shown in the banner
	- parameter animated:			Flag indicating if the showing is animated
	- parameter containerView:		The view to which the banner is added
	- parameter offset:				The vertical offset of the banner from the top of the view
	*/
	func showBanner( with title: String, animated: Bool, containerView: UIView, offset: CGFloat ) {
		// Do we have a banner already? Yes.
		guard Global.banner == nil else { return }
		
		let bannerView = createBanner( with: title, animated: animated )
		bannerView.translatesAutoresizingMaskIntoConstraints = false

		// center the banner and apply the vertical offset.
		containerView.addSubview( bannerView )
		NSLayoutConstraint.activate([
			bannerView.topAnchor.constraint( equalTo: containerView.topAnchor, constant: offset ),
			bannerView.centerXAnchor.constraint( equalTo: containerView.centerXAnchor ),
			bannerView.leadingAnchor.constraint( greaterThanOrEqualTo: containerView.leadingAnchor )
		])
		
		// Store the banner in the global banner variable
		Global.banner = bannerView
	}

	/// Returns whether the banner is currently visible.
	func bannerIsVisible() -> Bool {
		return Global.banner != nil
	}

	/**
	Hides the banner from the view in which is currently embedded.

	- parameter animated:	`true` if there should be a fade out and scale down animation that should create the hiding effect. `false` if the hiding should be instant.
	*/
	func hideBanner( animated: Bool ) {
		// No banner visible, return.
		guard let banner = Global.banner else { return }

		UIView.animate( withDuration: (animated ? Theme.Durations.standardAnimationDuration : 0), animations: {
			banner.alpha = 0
			banner.transform = CGAffineTransform( scaleX: Constants.smallScale, y: Constants.smallScale )
		}, completion: { _ in
			// Removing from superview should be fine, the Global.banner variable is _weak_ hence it will be cleared up.
			banner.removeFromSuperview()
		}) 
	}
}
