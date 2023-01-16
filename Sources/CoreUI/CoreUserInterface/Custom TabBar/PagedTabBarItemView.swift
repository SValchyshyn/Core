//
//  PagedTabBarItemView.swift
//  CoreUserInterface
//
//  Created by Andriy Tkach on 1/25/21.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import UIKit

public class PagedTabBarItemView: UIControl {
	
	private enum Constants {
		static let indicatorHeight: CGFloat = 2.0
		static let highlightColorAlpha: CGFloat = 0.2
		static let horizontalPadding: CGFloat = 12.0
	}
	
	// MARK: - Private UI elements
	
	private let titleLabel = UILabel()
	
	// MARK: - Public
	
	// Layout guidelines which are used for placing indicator view to visualize selected state
	let indicatorLayoutGuide = UILayoutGuide()
	
	// Callback to handle tap action
	var tapAction: ((PagedTabBarItemView) -> Void)?
	
	var title: String? {
		get { titleLabel.text }
		set { titleLabel.text = newValue }
	}
	
	var titleNormalColor: UIColor? {
		didSet { updateUI() }
	}
	
	var titleSelectedColor: UIColor? {
		didSet { updateUI() }
	}
	
	var titleFont: UIFont? {
		didSet { updateUI() }
	}
	
	// MARK: Public init
	
	public init(with title: String) {
		super.init(frame: .zero)
		
		privateInit()
		titleLabel.text = title
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)

		privateInit()
	}
	
	private func privateInit() {
		backgroundColor = colorsContent.colorSurface
		
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textAlignment = .center
		addSubview(titleLabel)
		
		addLayoutGuide(indicatorLayoutGuide)
		
		addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
			titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: Constants.horizontalPadding),
			titleLabel.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: Constants.horizontalPadding),
			indicatorLayoutGuide.heightAnchor.constraint(equalToConstant: Constants.indicatorHeight),
			indicatorLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
			indicatorLayoutGuide.widthAnchor.constraint(equalTo: widthAnchor),
			indicatorLayoutGuide.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
		
		updateUI()
	}
	
	// MARK: - Private
	
	private func updateUI() {
		titleLabel.textColor = textColor
		titleLabel.font = textFont
		backgroundColor = highlightBackgroundColor
	}
	
	// MARK: - Event handling
	
	@objc func touchUpInside(_ sender: AnyObject) {
		tapAction?(self)
	}
}

// MARK: - Properties to define colors/fonts for different states

extension PagedTabBarItemView {
	
	private var textFont: UIFont {
		titleFont ?? fontProvider[.medium(.caption)]
	}
	
	private var textColor: UIColor {
		switch state {
		case .selected, [.selected, .highlighted]: return titleSelectedColor ?? colorsContent.primaryColor
		case .highlighted: return colorsContent.bodyTextColor
		case .normal: return titleNormalColor ?? colorsContent.bodyTextColor
		case .disabled: return colorsContent.inactiveColor
		default: return colorsContent.bodyTextColor
		}
	}
	
	private var highlightBackgroundColor: UIColor  {
		switch state {
		case .selected:
			return colorsContent.colorSurface
			
		case .highlighted, [.selected, .highlighted]:
			return (titleSelectedColor ?? colorsContent.primaryColor).withAlphaComponent(Constants.highlightColorAlpha)
			
		case .normal:
			return colorsContent.colorSurface
			
		case .disabled:
			return colorsContent.colorSurface
			
		default: return colorsContent.colorSurface
		}
	}
}

extension PagedTabBarItemView {
	public override var isEnabled: Bool {
		didSet {
			updateUI()
		}
	}
	
	public override var isHighlighted: Bool {
		didSet {
			updateUI()
		}
	}
	
	public override var isSelected: Bool {
		didSet {
			updateUI()

			// As requested by the AQA team, if the item is selected we send a string, otherwise we don't
			accessibilityIdentifier = isSelected ? "selected" : ""
		}
	}
}
