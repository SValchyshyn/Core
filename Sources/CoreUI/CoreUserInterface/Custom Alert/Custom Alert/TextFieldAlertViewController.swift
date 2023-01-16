//
//  TextFieldAlertViewController.swift
//  CoreUserInterface
//
//  Created by Coruț Fabrizio on 02.03.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit
import Log

open class TextFieldAlertViewController: CustomAlertViewController<UITextField>, UITextFieldDelegate {

	private enum Constants {

		/// The space between the textField and the top of the container in which it has been added.
		static let spaceToTop: CGFloat = 8.0

		/// The space between the textField and the bottom of the container in which it has been added.
		static let spaceToBottom: CGFloat = 32.0
		static let textFieldHeight: CGFloat = 40.0

		/// The leading space that the textField has inside the `backgroundView`.
		static let horizontalOffset: CGFloat = 10.0
		
		/// The corner radius for `backgroundView`.
		static let backgroundViewCornerRadius: CGFloat = 5.0
	}

	// MARK: - View lifecycle.

	open override func viewDidLoad() {
		super.viewDidLoad()

		// Intercept delegate calls to the UITextField.
		customComponent.delegate = self
		customComponent.textColor = Theme.Colors.darkGray
		customComponent.font = fontProvider[.medium( .body )]

		// Make sure to adjust the UI based if the keyboard is displayed.
		NotificationCenter.default.addObserver( self, selector: #selector( keyboardWillShowNotificationReceived(_:) ), name: UIResponder.keyboardWillShowNotification, object: nil )
	}

	// MARK: - Selectors.

	@objc private func keyboardWillShowNotificationReceived( _ notification: Notification ) {
		guard let info = notification.userInfo,
			let keyboardRect = info[ UIResponder.keyboardFrameEndUserInfoKey ] as? CGRect else { return }

		// Adapt the UI for when the keyboard is presented.
		prepareUIForKeyboard( adjustmentOffset: -keyboardRect.size.height / 2 )
	}

	// MARK: - UITextFieldDelegate methods.

	// If the view controller is set as the text field's delegate, this method will simply perform the top action
	public func textFieldShouldReturn( _ textField: UITextField ) -> Bool {
		if remoteLoggingAlerts.isEnabled {
			Log.technical.log(.notice, "Closing alert due to text field delegate method", [.identifier("CustomAlertViewController.textFieldShouldReturn")])
		}

		// Consider the return key as if we've pressed the button on the alert.
		// Make sure we're not configuring the alert to have a bottom button instead of a top one ~ for visual representation reasons.
		if configuration.topButton != nil {
			topButtonAction( nil )
		} else if configuration.bottomButton != nil {
			bottomButtonAction( nil )
		}
		return false
	}

	// MARK: - Utils.

	override public func positionCustomControl( in containerView: UIView ) {
		let backgroundView = UIView()
		backgroundView.layer.borderWidth = 1
		backgroundView.layer.borderColor = Theme.Colors.gray.cgColor
		backgroundView.layer.cornerRadius = Constants.backgroundViewCornerRadius
		backgroundView.layer.masksToBounds = true
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview( backgroundView )

		NSLayoutConstraint.activate( [
			backgroundView.heightAnchor.constraint( equalToConstant: Constants.textFieldHeight ),
			// Pin the backgroundView to the horizontal edges.
			backgroundView.leadingAnchor.constraint( equalTo: containerView.leadingAnchor, constant: customConfiguration.customContentPadding.left ),
			backgroundView.centerXAnchor.constraint( equalTo: containerView.centerXAnchor ),
			// Allow some space on the top and on the bottom.
			backgroundView.topAnchor.constraint( equalTo: containerView.topAnchor, constant: Constants.spaceToTop + customConfiguration.customContentPadding.top ),
			containerView.bottomAnchor.constraint( equalTo: backgroundView.bottomAnchor, constant: Constants.spaceToBottom + customConfiguration.customContentPadding.bottom )
		] )

		// Remove the customComponent from the containerView and add it as a subview to the backgroundView.e
		customComponent.removeFromSuperview()
		backgroundView.addSubview( customComponent )

		NSLayoutConstraint.activate( [
			// Position the custom control horizontally.
			customComponent.leadingAnchor.constraint( equalTo: backgroundView.leadingAnchor, constant: Constants.horizontalOffset ),
			customComponent.centerXAnchor.constraint( equalTo: backgroundView.centerXAnchor ),
			// Pin the customComponent to the backgroundView's vertical edges.
			customComponent.topAnchor.constraint( equalTo: backgroundView.topAnchor ),
			customComponent.bottomAnchor.constraint( equalTo: backgroundView.bottomAnchor )
		] )
	}
}
