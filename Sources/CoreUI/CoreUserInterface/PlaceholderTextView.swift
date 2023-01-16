//
//  PlaceholderTextView.swift
//  CoopUI
//
//  Created by Marian Hunchak on 11.02.2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import UIKit

@IBDesignable public class PlaceholderTextView: UITextView {
	
	/// The UITextView placeholder text
	@IBInspectable public var placeholder: String? {
		get { placeholderLabel.text }
		set { placeholderLabel.text = newValue }
	}
	
	/// The UITextView placeholder color
	@IBInspectable public var placeholderColor: UIColor = .lightGray {
		didSet { placeholderLabel.textColor = placeholderColor }
	}
	
	public override var text: String! {
		didSet { handleTextDidChange() }
	}
	
	/// Adds a placeholder UILabel to this UITextView
	private lazy var placeholderLabel: UILabel = {
		let placeholderLabel = UILabel()
		placeholderLabel.font = font
		placeholderLabel.textColor = placeholderColor
		placeholderLabel.isHidden = !text.isEmpty
		placeholderLabel.numberOfLines = 0
		
		return placeholderLabel
	}()
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		commonInit()
	}
	
	private func commonInit() {
		addSubview(placeholderLabel)
		placeholderLabel.activate([
			placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top),
			placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: textContainerInset.bottom),
			placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: textContainer.lineFragmentPadding),
			placeholderLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -2 * textContainer.lineFragmentPadding)
		])
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(handleTextDidChange),
											   name: UITextView.textDidChangeNotification,
											   object: nil)
	}
	
	/// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
	@objc private func handleTextDidChange() {
		placeholderLabel.isHidden = !text.isEmpty
	}
	
}
