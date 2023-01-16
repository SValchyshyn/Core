//
//  FadeScrollView.swift
//  CoopUI
//
//  Created by Andriy Tkach on 8/17/21.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import UIKit

/**
View with shows top/bottom gradient effect if there is some content on top/bottom.
Just to make visual hint to users that more content is located on top/bottom area.
*/
public class FadeScrollView: UIScrollView, UIScrollViewDelegate {
	
	let fadePercentage: Double = 0.05
	let gradientLayer = CAGradientLayer()
	let opaqueColor = UIColor.black.cgColor
	
	var topOpacity: CGColor {
		let scrollViewHeight = frame.size.height
		let scrollContentSizeHeight = contentSize.height
		let scrollOffset = contentOffset.y
		
		let alpha: CGFloat = (scrollViewHeight >= scrollContentSizeHeight || scrollOffset <= 0) ? 1 : 0
		
		let color = UIColor(white: 0, alpha: alpha)
		return color.cgColor
	}
	
	var bottomOpacity: CGColor {
		let scrollViewHeight = frame.size.height
		let scrollContentSizeHeight = contentSize.height
		let scrollOffset = contentOffset.y
		
		let alpha: CGFloat = (scrollViewHeight >= scrollContentSizeHeight || scrollOffset + scrollViewHeight >= scrollContentSizeHeight) ? 1 : 0
		
		let color = UIColor(white: 0, alpha: alpha)
		return color.cgColor
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		self.delegate = self
		let maskLayer = CALayer()
		maskLayer.frame = self.bounds
		
		gradientLayer.frame = CGRect(x: self.bounds.origin.x, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
		gradientLayer.colors = [topOpacity, opaqueColor, opaqueColor, bottomOpacity]
		gradientLayer.locations = [0, NSNumber(value: fadePercentage), NSNumber(value: 1 - fadePercentage), 1]
		maskLayer.addSublayer(gradientLayer)
		
		self.layer.mask = maskLayer
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		gradientLayer.colors = [topOpacity, opaqueColor, opaqueColor, bottomOpacity]
	}
}
