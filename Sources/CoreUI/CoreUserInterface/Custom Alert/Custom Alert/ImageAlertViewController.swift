//
//  ImageAlertViewController.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 02.03.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit
import Core

public final class ImageAlertViewController: CustomAlertViewController<UIImageView> {

	private enum Constants {

		/// Fixed height of the imageView.
		static let bigImageHeight: CGFloat = 170.0
		static let mediumImageHeight: CGFloat = 100.0

		/// Aspect ratio of the imageView.
		static let bigAspectRatio: CGFloat = 170 / 250.0
		static let mediumAspectRatio: CGFloat = 100 / 200.0

		/// Space between the imageView and the top of the container view.
		static let bigTopSpace: CGFloat = 16.0
		static let mediumTopSpace: CGFloat = 30.0

		/// Space between the imageView and the bottom of the container view.
		static let bigBottomSpace: CGFloat = 16.0
		static let mediumBottomSpace: CGFloat = 35.0
	}

	/// Used to define how to display the image inside the alert.
	public enum ImageStyle {

		/// The image has a bigger aspect ratio and less space to the margins, hence, occupying more space within the same area.
		case big

		/// The image has a normal aspect ratio and spacing.
		case medium
	}

	/// Further personalizes the `ImageAlertViewController` compared to the `BasicAlertViewController.Configuration`.
	final public class Configuration: CustomConfiguration {

		/// `true` if the constraints should allow the image to be at a larger scale.
		public let imageStyle: ImageStyle

		/// The content of the `UIImageView`.
		public let image: UIImage

		/// - Parameters:
		///   - presentationStyle: 	Defines how the alert should be positioned on the screen.
		///   - displayingBigImage: `true` if the constraints should allow the image to be at a larger scale.
		///   - image: The content of the `UIImageView`.
		///   - seeMoreMessage: See more message. Only shown in `Debug` configuration.
		///   - accessibilityIdentifier: Identifier used for finding the alert during UI tests.
		public init( imageStyle: ImageStyle = .medium,
					 image: UIImage,
					 presentationStyle: PresentationStyle = .fullWidth,
					 seeMoreMessage: String? = nil,
					 accessibilityIdentifier: String? = nil,
					 contentPlacement: CustomConfiguration.ContentPlacement = .middle,
					 customContentPadding: UIEdgeInsets = .zero ) {
			self.imageStyle = imageStyle
			self.image = image
			super.init(
				presentationStyle: presentationStyle,
				seeMoreMessage: seeMoreMessage,
				accessibilityIdentifier: accessibilityIdentifier,
				contentPlacement: contentPlacement,
				customContentPadding: customContentPadding
			)
		}
	}

	// MARK: - Properties.

	/// Used to customize the the images.
	let imageConfiguration: ImageAlertViewController.Configuration

	// MARK: - Init.

	public init( info: AlertRepresentableInfo, configuration: ImageAlertViewController.Configuration ) {
		self.imageConfiguration = configuration
		super.init( info: info, configuration: configuration )
	}

	public required init?( coder: NSCoder ) {
		fatalError( "init(coder:) has not been implemented" )
	}

	// MARK: - Utils

	public override func setupUI() {
		super.setupUI()

		// Customize the content.
		customComponent.contentMode = .scaleAspectFit
		customComponent.image = imageConfiguration.image
	}

	public override func positionCustomControl( in containerView: UIView ) {
		let height: CGFloat
		let aspectRatio: CGFloat
		let topConstraintConstant: CGFloat
		let bottomConstraintConstant: CGFloat
		switch imageConfiguration.imageStyle {
		case .big:
			height = Constants.bigImageHeight
			aspectRatio = Constants.bigAspectRatio
			topConstraintConstant = Constants.bigTopSpace
			bottomConstraintConstant = Constants.bigBottomSpace

		case .medium:
			height = Constants.mediumImageHeight
			aspectRatio = Constants.mediumAspectRatio
			topConstraintConstant = Constants.mediumTopSpace
			bottomConstraintConstant = Constants.mediumBottomSpace
		}

		// Set a lower than maximum priority to the heightConstraint so it can be broken if somehow
		// the containerView in which the UIImageView is added has the width/ height less than the one yielded
		// by the combination of fixed height and aspect ratio constraints.
		let heightConstraint = customComponent.heightAnchor.constraint( equalToConstant: height )
		heightConstraint.priority = .init( 999 )

		// Position the image according to the style.
		NSLayoutConstraint.activate( [
			// Constrain its size.
			heightConstraint,
			customComponent.leadingAnchor.constraint( greaterThanOrEqualTo: containerView.leadingAnchor, constant: customConfiguration.customContentPadding.left ),
			customComponent.heightAnchor.constraint( equalTo: customComponent.widthAnchor, multiplier: aspectRatio ),
			// Center it horizontally in the container.
			customComponent.centerXAnchor.constraint( equalTo: containerView.centerXAnchor ),
			customComponent.topAnchor.constraint( equalTo: containerView.topAnchor, constant: topConstraintConstant + customConfiguration.customContentPadding.top ),
			containerView.bottomAnchor.constraint( equalTo: customComponent.bottomAnchor, constant: bottomConstraintConstant + customConfiguration.customContentPadding.bottom )
		] )
	}
}
