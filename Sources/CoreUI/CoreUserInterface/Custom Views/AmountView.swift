//
//  AmountView.swift
//  CoreUserInterface
//
//  Created by Georgi Damyanov on 30/08/2021.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import UIKit
import Core

/*
Android counterpart and the corresponding fields on iOS.

<attr name="integerDefault" format="string" />				-> will be empty for iOS
<attr name="decimalDefault" format="string" />				-> will be empty for iOS
<attr name="decimalTextColor" format="color" />				-> all the labels will have the same color.
<attr name="symbolTextColor" format="color" />				-> all the labels will have the same color.

<attr name="includeDecimalSeparator" format="boolean" />	-> not supported for now
<attr name="pattern" format="string" />						-> not supported for now

<attr name="decimalSeparator" format="string" />			-> AmountView.decimalSeparator
<attr name="symbol" format="string" /> 						-> AmountView.symbol
<attr name="amount" format="float" /> 						-> AmountView.amount
<attr name="symbolMargin" format="dimension" />				-> AmountView.symbolMargin
<attr name="decimalMargin" format="dimension" />			-> AmountView.decimalMargin
<attr name="decimalTextSize" format="dimension" />			-> AmountView.decimalFontSize
<attr name="decimalTextStyle" format="enum">				-> AmountView.decimalType
<enum name="normal" value="1" />
<enum name="small" value="2" />
</attr>
<attr name="decimalGravity">								-> AmountView.decimalAlignment
<!-- Push object to the top of its container, not changing its size. -->
<flag name="top" value="48" />
<!-- Push object to the bottom of its container, not changing its size. -->
<flag name="bottom" value="80" />
</attr>
<attr name="symbolTextSize" format="dimension" />			-> AmountView.symbolFontSize
<attr name="symbolTextStyle" format="enum">
<enum name="normal" value="1" />
<enum name="small" value="2" />
</attr>
<attr name="symbolGravity">									-> AmountView.symbolGravity; iOS only has top, bottom, center.
<!-- Push object to the top of its container, not changing its size. -->
<flag name="top" value="48" />
<!-- Push object to the bottom of its container, not changing its size. -->
<flag name="bottom" value="80" />
<!-- Push object to the left of its container, not changing its size. -->
<flag name="left" value="3" />
<!-- Push object to the right of its container, not changing its size. -->
<flag name="right" value="5" />
</attr>
<attr name="symbolAlignment">								-> AmountView.symbolPosition
<flag name="start" value="1"/>
<flag name="end" value="2"/>
</attr>
*/

/// View containing an amount with a decimal value and currency
public final class AmountView: UIView {
	
	/// Defines the arrangement of the `currency` and `decimals`.
	public enum Mode {
		/// The `decimals` will sit on top of the `currency`.
		case vertical
		
		/// The `decimals` and `currency` will be laid out on the same line.
		case horizontal
	}
	
	public enum Constants {
		/// Ratio between the `subscript label font size` and the `amount label font size`.
		public static let subscriptFontRatio: CGFloat = 3.0 / 5
	}
	
	// MARK: - UI
	
	/// Used for displaying the `currency symbol`.
	private lazy var _currencyLabel: UILabel = createAmountViewLabel()
	
	/// Used for displaying the integer part of the `amount`.
	private lazy var _amountLabel: UILabel = createAmountViewLabel()
	
	/// Used to displaying the `decimal part` of the amount.
	private lazy var _decimalLabel: UILabel = createAmountViewLabel()
	
	/// A stack view containing the amount label, the decimal label and the currency label
	private let _mainStackView = UIStackView()
	
	/// A view positioned to the right of the amount label
	private let _rightContentView = UIView()
	
	/// A view positioned to the left of the amount label
	private let _leftContentView = UIView()
	
	// MARK: - Dependencies.
	
	/// Customizes the color of the text in the labels.
	@Injectable
	private var _colors: ColorsProtocol
	
	/// A default value will be provided which contains the base, default information specific to every country and its `amount layout`.
	/// Re-setting the value will trigger an appearance update.
	public var configuration: Configuration = .init() {
		didSet {
			// Re-set the appearance of the view.
			updateText()
			updateLayout()
		}
	}
	
	/// Color of all the `price` and `currecny` will have.
	public var textColor: UIColor? {
		get { _amountLabel.textColor }
		set {
			newValue.map {
				_amountLabel.textColor = $0
				_decimalLabel.textColor = $0
				_currencyLabel.textColor = $0
			}
		}
	}
	
	/// Amount of money to be displayed
	public var amount: Double? {
		didSet { updateText() }
	}
	
	// MARK: - Init.
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	private func commonInit() {
		// Add the basic views which are not influenced by the current configuration
		addSubview(_mainStackView)
		backgroundColor = .clear
		_mainStackView.pinEdges(to: self)
		// The order is important, keep it like this.
		_mainStackView.addArrangedSubview(_leftContentView)
		_mainStackView.addArrangedSubview(_amountLabel)
		_mainStackView.addArrangedSubview(_rightContentView)
		_decimalLabel.translatesAutoresizingMaskIntoConstraints = false
		_currencyLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		updateText()
		updateLayout()
	}
	
	// MARK: - Private interface.
	
	/// Re-renders the textual information.
	private func updateText() {
		updateFonts()
		updateAmountText()
		updateCurrencyText()
	}
	
	/// Re-renders the labels in a different layout dictated by the configuration.
	private func updateLayout() {
		configureConstraints()
	}
	
	/// Setup the constraints necessary for the current configuration
	private func configureConstraints() {
		// Since the currency and decimals can vary bsed on language/ configurations
		// remove them from the current setup so that we can add them afterwards.
		_currencyLabel.removeFromSuperview()
		// Remove the decimalLabel and add it again so we do not have to keep track of individual constraints.
		_decimalLabel.removeFromSuperview()
		
		// MARK: - Decimals.
		
		_rightContentView.addSubview(_decimalLabel)
		// The decimals will always have the leading constraint to the rightContentView since it doesn't make
		// any sense in other configurations/ layouts.
		_decimalLabel.leadingAnchor.constraint(equalTo: _rightContentView.leadingAnchor, constant: configuration.decimalMargin).isActive = true
		constrainAmountAndDecimalsHorizontally()
		
		// MARK: - Symbol.
		
		// First determine where to put the currency and decimal labels.
		let constraints: [NSLayoutConstraint]
		switch (configuration.symbolPosition, configuration.decimalAlignment) {
		// If the currency symbol is laid out in the front of the amount, then we do not need to take into consideration the
		// decimals positions. It's always in the _rightContentView.
		case (.start, _):
			_leftContentView.addSubview(_currencyLabel)
			constraints = [
				// Constrain the currency to start where the amount label starts, vertically.
				_currencyLabel.firstBaselineAnchor.constraint(equalTo: _amountLabel.firstBaselineAnchor),
				// Pin it horizontally.
				_currencyLabel.leadingAnchor.constraint(equalTo: _leftContentView.leadingAnchor),
				_currencyLabel.trailingAnchor.constraint(equalTo: _leftContentView.trailingAnchor),
				_decimalLabel.trailingAnchor.constraint(equalTo: _rightContentView.trailingAnchor)
			]
			
		// The currency and decimals are on the right side of the amount.
		case (.end, .horizontal):
			_rightContentView.addSubview(_currencyLabel)
			
			constraints = [
				// Constrain the currency to start where the amount label starts, horizontally.
				_currencyLabel.leadingAnchor.constraint(equalTo: _decimalLabel.trailingAnchor, constant: configuration.symbolMargin),
				_currencyLabel.firstBaselineAnchor.constraint(equalTo: _amountLabel.firstBaselineAnchor),
				_currencyLabel.trailingAnchor.constraint(equalTo: _rightContentView.trailingAnchor)
			]
			
		case (.end, .vertical):
			_rightContentView.addSubview(_currencyLabel)
			constraints = [
				// Usually the decimals are larger than the currency text, so we'll use it as a reference for the width of the _rightContentView.
				_decimalLabel.trailingAnchor.constraint(equalTo: _rightContentView.trailingAnchor),
				// The currency label will be placed under the decimal label.
				_currencyLabel.firstBaselineAnchor.constraint(equalTo: _amountLabel.firstBaselineAnchor),
				_currencyLabel.trailingAnchor.constraint(equalTo: _decimalLabel.trailingAnchor)
			]
		}
		NSLayoutConstraint.activate(constraints)
	}
	
	/// Adds the required constraints such that the vertical position of where the text in `decimalLabel` starts will be synchronized
	/// with the vertical position of where the text in `amountLabel` starts. Basically aligning the tops of the labels such that it gives a superscript effect
	/// if required. Also fixes a possible `UIStackView` layout problem.
	func constrainAmountAndDecimalsHorizontally() {
		if case .horizontal = configuration.decimalAlignment, case .normal = configuration.decimalType {
			// If the decimalType is normal and the alignment is horizontal, there is a high chance that
			// the decimal separator to increase the line height of the decimals label making it bigger than the amoutLabel.
			// this will cause a visual glitch as described in: https://useyourloaf.com/blog/stack-view-baseline-alignment-issue/
			_amountLabel.translatesAutoresizingMaskIntoConstraints = false
			_decimalLabel.heightAnchor.constraint(lessThanOrEqualTo: _amountLabel.heightAnchor).isActive = true
		}

		// If the decimalAlignment == .vertical, a decimalType == .normal doesn't make sense
		// since in the same space we have to fit the symbol as well, hence, we'll treat the decimals
		// as if the decimalType == .small
		
		// If the decimalAlignment == .horizontal, but the decimalType == .small
		// No extra setup required if the decimals are smaller than the amount view.
		
		// When trying to align the amountLabel and decimalLabl tops, considering their different fontSize,
		// that cannot be sometimes achievable through .topAnchor since fonts might have extra space at the top
		// which, scaled because of the size difference, will not make the top of the texts sync perfectly.
		// This baseline approach uses font properties and the baseline (which is agnostic to size):
		// the capHeight is the distance from the baseline to the line determined by the highest point that the font has for capital letters.
		let amountFont = configuration.amountFont()
		let decimalsFont = configuration.decimalsFont()
		// A very interesting depiction of fonts: https://stackoverflow.com/a/45253102
		// For the situation in which both the amount and the decimals will have the same font, there will basically be a baseline alignment which is all good.
		_amountLabel.firstBaselineAnchor.constraint(equalTo: _decimalLabel.firstBaselineAnchor, constant: amountFont.capHeight - decimalsFont.capHeight).isActive = true
	}
	
	/// Update the integer and decimal labels
	private func updateAmountText() {
		guard let amount = amount, let (integerPart, decimalPart) = configuration.getIntegerAndDecimalPart( from: amount ) else { return }
		_amountLabel.text = integerPart
		updateDecimalsText( decimalValue: decimalPart )
	}
	
	/// Update the currency label with the correct symbol
	private func updateCurrencyText() {
		guard !configuration.symbol.isEmpty else {
			_currencyLabel.text = configuration.symbol
			return
		}
		
		// Add space after symbol if symbol is at the beginning, otherwise add space before symbol
		let symbol = configuration.symbolPosition == .start ? "\(configuration.symbol) " : " \(configuration.symbol)"
		
		// Apply capitalization type
		_currencyLabel.text = configuration.symbolCapitalization.cast( symbol )
	}
	
	/// Update the `decimals` and add the `separator` if needed.
	private func updateDecimalsText( decimalValue: String ) {
		let decimals: String
		if configuration.decimalType == .normal && !decimalValue.isEmpty {
			// If we have decimals, display the decimalSeparator only if we have normal display time.
			// Small display type would not require a decimal separator because the decimals will be differentiated by the gravity.
			// If we don't have decimals, then the decimalType doesn't really matter.
			decimals = configuration.decimalSeparator.rawValue + decimalValue
		} else {
			// Otherwise, leave the value as is.
			decimals = decimalValue
		}
		_decimalLabel.text = decimals
	}
	
	/// Update the fonts for all the labels.
	/// Local customizations have precedence over the `configuration`.
	private func updateFonts() {
		_amountLabel.font = configuration.amountFont()
		_currencyLabel.font = configuration.currencyFont()
		_decimalLabel.font = configuration.decimalsFont()
	}
	
	/// - Returns: A `UILabel` whose characteristincs and style is specific to the `AmountView`.
	private func createAmountViewLabel() -> UILabel {
		let label = UILabel()
		label.textColor = _colors.colorSurface
		
		// Set the priorities as .required such that if the AmountView is not constrained
		// it will have an intrinsicContentSize defined by its contents, depending on how they are positioned.
		label.setContentHuggingPriority(.required, for: .horizontal)
		label.setContentHuggingPriority(.required, for: .vertical)
		label.setContentCompressionResistancePriority(.required, for: .horizontal)
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}
}
