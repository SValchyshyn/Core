//
//  HighlightButton.swift
//  CoopUI
//
//  Created by Coruț Fabrizio on 20/11/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import UIKit

/// Button that creates a highlight effect over the content when pressed/ holding on it.
public final class HighlightButton: UIButton {
	// MARK: - Properties.

	/// Used to simulate the hightlight effect.
	private var _highlightView: UIView?

	/// The color of the hightlight. Defaults to `UIColor.black.withAlphaComponent( 0.4 )`.
	@IBInspectable
	public var highlightColor: UIColor = UIColor.black.withAlphaComponent( 0.4 )

	// MARK: - Init override.

	public init() {
		super.init( frame: .zero )
		customInit()
	}

	public override init( frame: CGRect ) {
		super.init( frame: frame )
		customInit()
	}

	required init?( coder: NSCoder ) {
		super.init( coder: coder )
		customInit()
	}

	// MARK: - Private custom init.

	/// Creates the functionality that
	private func customInit() {
		// Create the view that makes the highlight possible.
		let highlightView = UIView()
		highlightView.isUserInteractionEnabled = false

		// Constraint the view. to be as big as the button.
		highlightView.translatesAutoresizingMaskIntoConstraints = false
		addSubview( highlightView )
		highlightView.pinEdges( to: self )

		// Listen for meaningful events.
		// Listen for the touchDown so we know to start presenting the highlight effect.
		addTarget( self, action: #selector( highlightOn(_:) ), for: .touchDown )
		// Listen for the touchDrag, touchCancel, touchUpOutside so we know to dimiss the highlight effect.
		addTarget( self, action: #selector( highlightOff(_:) ), for: [.touchDragExit, .touchCancel, .touchUpOutside] )
		// Listen for the touchUpInside separately since sometimes the effect might be dismissed too fast. We programatically add a delay to the highlight dismiss.
		addTarget( self, action: #selector( touchAction(_:) ), for: .touchUpInside )

		// Keep a reference to the highlight view.
		_highlightView = highlightView
	}

	// MARK: - Selectors.

	@objc private func highlightOn( _ sender: UIButton ) {
		// Set the highlightColor on the view so we can create the effect.
		_highlightView?.backgroundColor = highlightColor
	}

	@objc private func highlightOff( _ sender: UIButton ) {
		// Remove the color from the view.
		_highlightView?.backgroundColor = .clear
	}

	@objc private func touchAction( _ sender: UIButton ) {
		// Remove the highlight color with a small delay
		DispatchQueue.main.asyncAfter( deadline: .now() + 0.15 ) {
			self.highlightOff( sender )
		}
	}
}
