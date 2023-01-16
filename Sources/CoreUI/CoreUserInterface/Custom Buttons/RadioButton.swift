//
//  RadioButton.swift
//  CoopUI
//
//  Created by Olexandr Belozierov on 09.03.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit
import Core

public class RadioButton: UIView {
	
	private enum Constants {
		static let centerViewWidth: CGFloat = 10
		static let viewWidth: CGFloat = 24
	}
	
	private let centerView = UIView()
	@Injectable private var colors: ColorsProtocol
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}
	
	private func initialize() {
		clipsToBounds = true
		layer.borderWidth = 1
		layer.borderColor = colors.dividerColor.cgColor
		
		addSubview(centerView)
		centerView.clipsToBounds = true
		centerView.backgroundColor = colors.colorSurface
		centerView.bounds.size = CGSize(width: Constants.centerViewWidth, height: Constants.centerViewWidth)
		centerView.layer.cornerRadius = Constants.centerViewWidth / 2
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		layer.cornerRadius = bounds.height / 2
		centerView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
	}
	
	public override var intrinsicContentSize: CGSize {
		CGSize(width: Constants.viewWidth, height: Constants.viewWidth)
	}
	
	public override var tintColor: UIColor! {
		didSet { setSelection(isSelected) }
	}
	
	public var isSelected: Bool {
		get { !centerView.isHidden }
		set { setSelection(newValue) }
	}
	
	private func setSelection(_ isSelected: Bool) {
		centerView.isHidden = !isSelected
		backgroundColor = isSelected ? tintColor : .clear
	}
	
}
