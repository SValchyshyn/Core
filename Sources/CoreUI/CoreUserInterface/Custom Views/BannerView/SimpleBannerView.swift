//
//  SimpleBannerView.swift
//  CoopM16
//
//  Created by Nis Wegmann on 23/08/2016.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit

/// Simple banner like view. Contains a simple label which is centered in the view.
/// Upon touching it performs a scale down animation and removes itself automatically from its `superview`.
public final class SimpleBannerView: UIView {

	public enum Constants {

		/// For how many seconds the view should animate upon being touched.
		static let animationDuration: TimeInterval = 0.4

		/// `CGAffineTransform` that should be applied to the view upon being touched.
		static let tapAnimationTransform: CGAffineTransform = .init( scaleX: 0.4, y: 0.4 )

		/// View corner radius.
		static public let cornerRadius: CGFloat = 4.0
	}

	// MARK: - Public interface.

	/// Remote data available popup delegate
	public weak var delegate: BannerViewDelegate?

	// MARK: - Init.

	/// - Parameters:
	///   - title: Will be displayed in the `label`.
	///   - padding: Value used to create the horizontal padding. `padding / 2` will be used for vertical padding. Default value: `20`.
	public init( with title: String, padding: CGFloat = 20.0 ) {
		// Super init is called only after the custom properties are set
		super.init( frame: .zero )

		let titleLabel = UILabel()
		titleLabel.text = title
		titleLabel.font = fontProvider[.regular(.body)]
		titleLabel.textColor = UIColor.white
		titleLabel.backgroundColor = UIColor.clear
		titleLabel.translatesAutoresizingMaskIntoConstraints = false

		// Position the label inside the view.
		addSubview( titleLabel )
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint( equalTo: topAnchor, constant: padding / 2 ),
			bottomAnchor.constraint( equalTo: titleLabel.bottomAnchor, constant: padding / 2 ),
			titleLabel.centerXAnchor.constraint( equalTo: centerXAnchor ),
			titleLabel.leadingAnchor.constraint( equalTo: leadingAnchor, constant: padding )
		])

		// Further customizations.
		backgroundColor = colorsContent.primaryColor
		layer.cornerRadius = Constants.cornerRadius

		// Make sure to intercept the tap events on the view.
		addGestureRecognizer( UITapGestureRecognizer( target: self, action: #selector( tapRecognizerHandler ) ) )
	}

	public required init?( coder aDecoder: NSCoder ) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Selectors.

	@objc private func tapRecognizerHandler() {
		// Notify the delegate before hiding.
		delegate?.bannerAction()

		// Hide self
		UIView.animate( withDuration: Constants.animationDuration, animations: {
			self.alpha = 0
			self.transform = Constants.tapAnimationTransform
		}, completion: { _ in
			self.removeFromSuperview()
		})
	}
}
