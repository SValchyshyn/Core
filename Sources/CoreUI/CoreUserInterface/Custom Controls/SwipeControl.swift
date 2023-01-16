//
//  SwipeControl.swift
//  CoopUI
//
//  Created by Georgi Damyanov on 02/09/16.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit

public class SwipeControl: UIControl {
	@IBInspectable public var handleColor: UIColor = UIColor.yellow {
		didSet {
			_thumbLayer.thumbColor = handleColor.cgColor
		}
	}
	@IBInspectable public var disabledHandleColor: UIColor = UIColor.yellow
	@IBInspectable public var cornerRadius: CGFloat = 25
	@IBInspectable public var thumbDiameter: CGFloat = 50
	@IBInspectable public var thumbChevronWidth: CGFloat = 1
	
	@IBInspectable public var titleLabelText: String = "" {
		didSet {
			updateTextLabel()
		}
	}
	
	@IBInspectable public var amountLabelText: String = "" {
		didSet {
			updateTextLabel()
		}
	}
	
	public var titleFont: UIFont = fontProvider[.regular(.body)] {
		didSet {
			updateTextLabel()
		}
	}
	
	public var amountFont: UIFont = fontProvider[.semibold(.body)] {
		didSet {
			updateTextLabel()
		}
	}
	
	@IBInspectable public var titleColor: UIColor = UIColor.black {
		didSet {
			_labelLayer.foregroundColor = titleColor.cgColor
		}
	}
	@IBInspectable public var disabledTitleColor: UIColor = UIColor.gray
	@IBInspectable public var swipeAreaBackgroundColor: UIColor = UIColor.orange {
		didSet {
			_trackLayer.backgroundColor = swipeAreaBackgroundColor.cgColor
		}
	}
	
	override public var frame: CGRect {
		didSet {
			super.frame = frame
		}
	}
	
	private var _panStartPoint: CGPoint!								// Set on UIGestureRecognizerStateBegan
	private var _thumbLayer: ThumbLayer!
	private var _trackLayer: TrackLayer!
	private var _labelLayer: CATextLayer!
	
	override public var isEnabled: Bool {
		didSet {
			// Update the title text color according to the current state
			if isEnabled {
				_thumbLayer.thumbColor = handleColor.cgColor
				_labelLayer.foregroundColor = titleColor.cgColor
			} else {
				_thumbLayer.thumbColor = disabledHandleColor.cgColor
				_labelLayer.foregroundColor = disabledTitleColor.cgColor
			}
			_thumbLayer.setNeedsDisplay()
		}
	}
	
	required init?( coder aDecoder: NSCoder ) {
		super.init( coder: aDecoder )
		privateInit()
	}
	
	override public func prepareForInterfaceBuilder() {
		// privateInit()
	}
	
	// The last known bounds
	private var lastKnownBounds: CGRect?
	
	override public func layoutSubviews() {
		// If the bounds have changed, update the frames of the sub-layers
		if bounds != lastKnownBounds {
			// Save the new bounds
			lastKnownBounds = bounds
			
			// Also adjust layer widths as they aren't adjusten when view's frame changes in response to auto-layout
			if _trackLayer != nil {
				_trackLayer.frame = self.bounds
			}
			if _labelLayer != nil {
				let size = (titleLabelText as NSString).size( withAttributes: [.font: titleFont] )
				let y = round(self.bounds.size.height/2 - size.height/2)
				let frame = CGRect(x: 0, y: y, width: self.bounds.size.width, height: self.bounds.size.height )
				_labelLayer.frame = frame
			}
			if _thumbLayer != nil {
				_thumbLayer.frame = CGRect( x: 0, y: (bounds.height-thumbDiameter)/2, width: thumbDiameter, height: thumbDiameter )
				_thumbLayer.chevronWidth = thumbChevronWidth
			}
		}
	}
	/**
	Reset the control to it's initial position
	*/
	public func resetControl() {
		_trackLayer.frame = bounds
		_thumbLayer.frame = CGRect( x: 0, y: (bounds.height-thumbDiameter)/2, width: thumbDiameter, height: thumbDiameter )
		_labelLayer.opacity = 1
	}
	
	override public func beginTracking( _ touch: UITouch, with event: UIEvent? ) -> Bool {
		let point = touch.location( in: self )
		
		if _thumbLayer.frame.contains(point ) {
			_panStartPoint = point
			return true
		} else {
			// Touch outside the thumb: ignore
			return false
		}
	}
	
	override public func continueTracking( _ touch: UITouch, with event: UIEvent? ) -> Bool {
		let point = touch.location( in: self )
		var offset = point.x - _panStartPoint.x
		
		// Check bounds
		if offset + _thumbLayer.bounds.size.width > self.bounds.size.width {
			offset = self.bounds.size.width - _thumbLayer.bounds.size.width
		}
		if offset < 0 {
			offset = 0
		}
		
		// Wrap in CATransaction with disabled actions so the frame is updated immediately and not animated
		CATransaction.begin()
		CATransaction.setDisableActions( true )
		_trackLayer.frame = CGRect( x: offset, y: 0, width: bounds.size.width - offset, height: bounds.size.height )
		_thumbLayer.frame = CGRect( x: offset, y: (bounds.height-thumbDiameter)/2, width: thumbDiameter, height: thumbDiameter )
		_labelLayer.opacity = Float( 1 - min( Float(1), Float(offset/self.frame.height)))
		CATransaction.commit()
		
		return true
	}
	
	override public func endTracking( _ touch: UITouch?, with event: UIEvent? ) {
		guard let touch = touch else {
			print( "No touch" )
			return
		}
		
		// Get offset and constrain to min/max
		let point = touch.location( in: self )
		var offset = point.x - _panStartPoint.x
		if offset + _thumbLayer.bounds.size.width > self.bounds.size.width {
			offset = self.bounds.size.width - _thumbLayer.bounds.size.width
		}
		if offset < 0 {
			offset = 0
		}
		
		// Find remaining distance and see if we're at the end of the track
		let remainingDistance = bounds.size.width - _thumbLayer.frame.size.width - offset
		if remainingDistance == 0 {
			// All the way: send touchUpInside
			self._trackLayer.frame = CGRect( x: self.bounds.size.width - _thumbLayer.bounds.size.width, y: 0, width: self.bounds.size.height, height: self.bounds.size.height )
			self._thumbLayer.frame = CGRect( x: self.bounds.size.width - _thumbLayer.bounds.size.width, y: (bounds.height-thumbDiameter)/2, width: thumbDiameter, height: thumbDiameter )
			sendActions( for: .primaryActionTriggered )	// I wanted to use .touchUpInside, but that one is automatically fired even if we don't do it manually? -JWJ
		} else {
			// Not all the way: animate back to starting posistion
			self._trackLayer.frame = bounds
			self._thumbLayer.frame = CGRect( x: 0, y: (bounds.height-thumbDiameter)/2, width: thumbDiameter, height: thumbDiameter )
			_labelLayer.opacity = 1
		}
	}
	
	// MARK: - Private functions
	
	private func privateInit() {
		// Track layer
		_trackLayer = TrackLayer()
		_trackLayer.contentsScale = UIScreen.main.scale
		_trackLayer.cornerRadius = cornerRadius
		_trackLayer.frame = self.bounds
		layer.addSublayer( _trackLayer )
		_trackLayer.setNeedsDisplay()
		
		// Label layer
		_labelLayer = CATextLayer()
		_labelLayer.contentsScale = UIScreen.main.scale
		_labelLayer.frame = self.bounds
		_labelLayer.alignmentMode = .center
		layer.addSublayer( _labelLayer )
		
		// Thumb layer
		_thumbLayer = ThumbLayer()
		_thumbLayer.contentsScale = UIScreen.main.scale
		_thumbLayer.frame = CGRect( x: 0, y: (bounds.height-thumbDiameter)/2, width: thumbDiameter, height: thumbDiameter )
		_thumbLayer.chevronWidth = thumbChevronWidth
		_thumbLayer.masksToBounds = true
		layer.addSublayer( _thumbLayer )
		_thumbLayer.setNeedsDisplay()
		
		accessibilityLabel = "Gennemfør betaling"
	}
	
	/**
	Concatenate title and amount label texts if there is room enough.
	IF there is room enough show both:
	e.g. "Betal kr. 1099,25"
	ELSE show only the title:
	e.g. "Betal"
	*/
	private func updateTextLabel() {
		// Short text e.g. "Betal"
		let shortText = NSAttributedString( string: titleLabelText, attributes: [.font: titleFont] )
		
		// Long text e.g. "Betal kr. 100,55"
		let longText = NSMutableAttributedString()
		longText.append( NSAttributedString( string: titleLabelText, attributes: [.font: titleFont] ))
		longText.append( NSAttributedString( string: amountLabelText, attributes: [.font: amountFont] ))
		
		let shortTextSize = shortText.size()
		let longTextSize = longText.size()
		
		// Calculate max text length padding with 10px padding
		let maxTextWidth = 2*(frame.width/2 - thumbDiameter) - 10
		
		// Is there room for the long text?
		if longTextSize.width < maxTextWidth {
			// Yes: Use long text
			var frame = _labelLayer.frame
			frame.origin.y = round(self.bounds.size.height/2 - longTextSize.height/2)
			_labelLayer.frame = frame
			_labelLayer.string = longText
		} else {
			// No: Only show the short text
			var frame = _labelLayer.frame
			frame.origin.y = round(self.bounds.size.height/2 - shortTextSize.height/2)
			_labelLayer.frame = frame
			_labelLayer.string = shortText
		}
		
		_labelLayer.setNeedsDisplay()
	}
}

// MARK: - ThumbLayer

/**
Layer class for the draggable thumb
*/
class ThumbLayer: CALayer {
	var chevronWidth: CGFloat = 1
	var thumbColor: CGColor = UIColor.red.cgColor
	
	override func draw( in ctx: CGContext ) {
		let path = UIBezierPath( ovalIn: bounds )
		ctx.addPath(path.cgPath )
		ctx.setFillColor(thumbColor )
		ctx.fillPath()
		
		// Draw chevron
		let chevronPath = UIBezierPath()
		ctx.setLineWidth( chevronWidth )
		ctx.setLineCap(.round )
		ctx.setLineJoin(.round )
		
		// Move the path to an initial point
		chevronPath.move( to: CGPoint( x: frame.height*(2/5), y: frame.height*0.3 ))
		
		// Draw a the first line of the chevron
		chevronPath.addLine( to: CGPoint( x: frame.height*(3/5), y: frame.height*0.5 ))
		
		// Draw a line second line of the chevron the bottom
		chevronPath.addLine( to: CGPoint( x: frame.height*(2/5), y: frame.height*0.7 ))
		
		// Draw the chevron
		ctx.addPath(chevronPath.cgPath )
		ctx.setStrokeColor(UIColor.white.cgColor )
		ctx.strokePath()
	}
}

/**
Layer class for the slider track.
*/
class TrackLayer: CALayer {
}
