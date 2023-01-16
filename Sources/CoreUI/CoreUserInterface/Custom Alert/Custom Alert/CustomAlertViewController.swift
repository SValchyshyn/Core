//
//  CustomAlertViewController.swift
//
//  Created by Jens Willy Johannsen on 04/09/15.
//  Copyright © 2015 Greener Pastures. All rights reserved.
//

import UIKit
import Core

public class CustomConfiguration: BasicAlertViewController.Configuration {

	public enum ContentPlacement {

		/// The `custom content` is placed between the top of the alert and the title.
		case top

		/// The `custom content` is placed between the `messageLabel` and the buttons.
		case middle
	}

	// MARK: - Properties.

	/// Determines where to place the content in the alert.
	public let contentPlacement: ContentPlacement

	/// Used to add spacing to the `customControl`
	public let customContentPadding: UIEdgeInsets

	// MARK: - Init.

	public init( presentationStyle: PresentationStyle = .fullWidth,
				 seeMoreMessage: String? = nil,
				 accessibilityIdentifier: String? = nil,
				 contentPlacement: ContentPlacement = .middle,
				 customContentPadding: UIEdgeInsets = .zero ) {
		self.contentPlacement = contentPlacement
		self.customContentPadding = customContentPadding
		super.init( presentationStyle: presentationStyle, seeMoreMessage: seeMoreMessage, accessibilityIdentifier: accessibilityIdentifier )
	}
}

open class CustomAlertViewController<T: UIView>: BasicAlertViewController {

	// MARK: - Properties.

	/// The custom component which the alert has been customized with.
	public let customComponent: T

	/// Provides extra information with regards to how to customize the content.
	let customConfiguration: CustomConfiguration

	// MARK: - Init.

	/// Creates an alert with the possibility of customizing the content.
	/// e.g. `CustomConfiguration.contentPlacement`
	///
	/// The most important thing to consider when customizing the alert is the fact that the `customComponent` with be pinned to the edges of the container accoring to `CustomConfiguration.customContentPadding`.
	public init( info: AlertRepresentableInfo, configuration: CustomConfiguration, customComponent: T ) {
		self.customComponent = customComponent
		self.customConfiguration = configuration
		super.init( info: info, configuration: configuration )
	}

	/// Creates an alert with the possibility of customizing the content.
	/// e.g. `CustomConfiguration.contentPlacement`
	///
	/// The most important thing to consider when customizing the alert is the fact that the `customComponent` with be pinned to the edges of the container accoring to `CustomConfiguration.customContentPadding`.
	public init( info: AlertRepresentableInfo, configuration: CustomConfiguration ) {
		self.customComponent = .init()
		self.customConfiguration = configuration
		super.init( info: info, configuration: configuration )
	}

	public required init?( coder: NSCoder ) {
		fatalError( "init(coder:) has not been implemented" )
	}

	// MARK: - View lifecycle.

	public override func loadView() {
		super.loadView()

		// Position and customize the layout for the custom control.
		addAndPositionCustomControl()
	}

	// MARK: - Utils.

	/// Adds the `customControl` to the subview in either `topCustomizationContainerView` or `bottomCustomizationContrierView`, based on the configuration.
	private func addAndPositionCustomControl() {
		// Determine where to place the custom content.
		let containerView: UIView
		switch customConfiguration.contentPlacement {
		case .top:
			containerView = topCustomizationContainerView

		case .middle:
			containerView = bottomCustomizationContainerView
		}

		// Add and position it.
		customComponent.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview( customComponent )
		positionCustomControl( in: containerView )
	}

	/// Constrains the `customView` in the provided container.
	/// - Parameter containerView: The `UIView` in which the `customView` has been added as a subview.
	open func positionCustomControl( in containerView: UIView ) {
		NSLayoutConstraint.activate( [
			// Horizontal positioning.
			customComponent.leadingAnchor.constraint( equalTo: containerView.leadingAnchor, constant: customConfiguration.customContentPadding.left ),
			containerView.trailingAnchor.constraint( equalTo: customComponent.trailingAnchor, constant: customConfiguration.customContentPadding.right ),
			// Vertical positioning.
			customComponent.topAnchor.constraint( equalTo: containerView.topAnchor, constant: customConfiguration.customContentPadding.top ),
			containerView.bottomAnchor.constraint( equalTo: customComponent.bottomAnchor, constant: customConfiguration.customContentPadding.bottom )
		] )
	}
}
