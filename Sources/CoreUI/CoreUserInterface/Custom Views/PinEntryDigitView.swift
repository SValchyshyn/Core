//
//  PinEntryDigit.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 27/05/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import Core

public class PinEntryDigitView: UIView {
	private struct Constants {
		static let cornerRadius: CGFloat = 5
		static let borderWidth: CGFloat = 1
		static let backgroundColor: UIColor = UIColor.white
	}

	/**
	Enum indicating if the digit view is currently empty, active or filled in.
	*/
	public enum State {
		case empty
		case active
		case full
	}
	
	@Injectable private var colors: ColorsProtocol

	@IBOutlet weak var dotImageView: UIImageView! {
		didSet {
			dotImageView.image = UIImage(named: "gfx_payment_dot", in: Bundle(for: PinEntryDigitView.self), compatibleWith: self.traitCollection )
		}
	}

	override public func awakeFromNib() {
		super.awakeFromNib()

		// Round the corners of the view
		layer.cornerRadius = Constants.cornerRadius
		clipsToBounds = true
	}

	public func updateState( _ state: State ) {
		// Update the UI according to the new state
		switch state {
		case .empty:
			layer.borderWidth = 0
			backgroundColor = Constants.backgroundColor
			dotImageView.isHidden = true

		case .active:
			layer.borderWidth = Constants.borderWidth
			layer.borderColor = colors.successColor.cgColor
			backgroundColor = UIColor.white
			dotImageView.isHidden = true

		case .full:
			layer.borderWidth = 0
			backgroundColor = Constants.backgroundColor
			dotImageView.isHidden = false
		}
	}
}
