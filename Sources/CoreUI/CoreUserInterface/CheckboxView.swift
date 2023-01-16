//
//  CheckboxView.swift
//  PlatformShoppingListUI
//
//  Created by Olexandr Belozierov on 21.12.2021.
//

import UIKit

@IBDesignable public class CheckboxView: UIView {
	
	private let imageView = UIImageView()
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		configure()
	}
	
	public override func tintColorDidChange() {
		super.tintColorDidChange()
		updateView()
	}
	
	public override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		updateView()
	}
	
	// MARK: - Configure
	
	private func configure() {
		configureLayer()
		configureImageView()
	}
	
	private func configureLayer() {
		layer.masksToBounds = true
		layer.borderWidth = 1
	}
	
	private func configureImageView() {
		imageView.image = UIImage(named: "checkmark", in: .CoreUIModule, compatibleWith: nil)
		imageView.tintColor = .white
		
		addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
	}
	
	// MARK: - Properties
	
	@IBInspectable public var isSelected: Bool = false {
		didSet { updateView() }
	}
	
	@IBInspectable public var borderColor: UIColor? {
		didSet { updateView() }
	}
	
	@IBInspectable public var fillBorderOnSelection: Bool = false {
		didSet { updateView() }
	}
	
	@IBInspectable public var cornerRadius: CGFloat = .zero {
		didSet { layer.cornerRadius = cornerRadius }
	}
	
	private func updateView() {
		imageView.isHidden = !isSelected
		backgroundColor = isSelected ? tintColor : .clear
		layer.borderColor = (isSelected && fillBorderOnSelection ? tintColor : borderColor)?.cgColor
	}
	
}
