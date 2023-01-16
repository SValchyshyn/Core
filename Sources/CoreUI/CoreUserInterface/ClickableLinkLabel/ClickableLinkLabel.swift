//
//  ClickableLinkLabel.swift
//  Danes Abroad
//
//  Created by Jens Willy Johannsen on 28/01/15.
//  Copyright (c) 2015 Greener Pastures. All rights reserved.
//

import UIKit

public protocol ClickableLinkLabelDelegate: AnyObject {
	/** This method will be called when a link is clicked (touches ended). */
	func clickedLinkWithURL(_ url: URL)
}

open class ClickableLinkLabel: UILabel {
	// Public properties
	open weak var linkDelegate: ClickableLinkLabelDelegate?

	/** Text attributes for links. Note that the font size will be ignored if the .matchFontSizeForLinks is true. If nil, the label's standard font plus underline is used. */
	open var linkTextAttributes: [NSAttributedString.Key: Any]? {
		didSet {
			if let attributes = linkTextAttributes {
				if let font = attributes[ NSAttributedString.Key.font ] as? UIFont, matchFontSizeForLinks {
					let fontWithCorrectSize = UIFont(name: font.fontName, size: self.font.pointSize)!
					linkTextAttributes![ NSAttributedString.Key.font ] = fontWithCorrectSize
				}
			}
		}
	}

	@IBInspectable public var lineHeight: CGFloat = 0

	/** If this is true the font size from the linkTextAttributes will be ignored and the font size will be set to the label font's size for links. */
	public var matchFontSizeForLinks: Bool = true

	/** If this is true, all links will be highlighted. Use this for debugging purposes */
	public var debugHighlightLinks: Bool = false

	open override var text: String? {
		get {
			return super.text
		}
		set {
			internalSetText(newValue)
		}
	}

	private var _rawText: String?
	open var rawText: String {
			return _rawText ?? ""
		}

	open override func awakeFromNib() {
		let currentText = super.text
		self.text = currentText
	}

	// Private
	fileprivate var _links = [NSTextCheckingResult]()

	/// Public, read-only access to all found URLs in the text.
	open var urls: [URL] {
		return _links.compactMap { $0.url }
	}

	fileprivate func internalSetText(_ text: String?) {
		if text == nil {
			super.text = text
			return
		}

		// Set the raw text
		_rawText = text

		let tmpText = NSMutableString()
		_links = [NSTextCheckingResult]()	// Clear existing links

		// Regex to find links
		do {
			var regex = try NSRegularExpression(pattern: "<\\s*[^>]*href\\s*=\\s*\"(.*?)\".*?>(.+?)</a>", options: [.caseInsensitive, .dotMatchesLineSeparators])

			// Match
			var lastLocation = 0
			var links = [String: NSRange]()
			var matches = regex.matches(in: text! as String, options: [], range: NSRange(location: 0, length: (text! as NSString).length))

			for match: NSTextCheckingResult in matches {
				// Make sure we have two captured groups
				assert(match.numberOfRanges == 3, "Wrong number of capture groups. Expected 3, got \(match.numberOfRanges)")

				// Append from last location up to beginning of first capture group
				tmpText.append((text! as NSString).substring(with: NSRange(location: lastLocation, length: match.range(at: 0).location - lastLocation)))

				let linkText = (text! as NSString).substring(with: NSRange(location: match.range(at: 2).location, length: match.range(at: 2).length)) as NSString
				let urlString = (text! as NSString).substring(with: NSRange(location: match.range(at: 1).location, length: match.range(at: 1).length))

				// Append link text
				tmpText.append(linkText as String)

				// Remember link URL and location as key/value in dictionary
				links[urlString] = NSRange(location: tmpText.length - linkText.length, length: linkText.length)

				// Update last location
				lastLocation = match.range(at: 0).location + match.range(at: 0).length
			}	// end for match in matches

			// Append remaining text
			tmpText.append((text! as NSString).substring(from: lastLocation))

			// Set text (attributed to set lineheight)
			super.text = String(tmpText)

			// Iterate all found links and attach
			for (urlString, range) in links {
				if let url = URL(string: urlString) {
					self.addLinkToURL(url: url, range: range)
				} else {
					NSLog("❌ Can't make URL from string: \(urlString)")
				}
			}

			// Regex to find URLs in the remaining text with <a href="">...</a> removed. Note: we are not modifying the `self.text` in this block.
			if let remainingText = self.text {
				regex = try NSRegularExpression(pattern: "http[s]?://[^\\s]+", options: .caseInsensitive)

				lastLocation = 0
				links = [String: NSRange]()
				matches = regex.matches(in: remainingText, options: [], range: NSRange(location: 0, length: remainingText.count))

				for match: NSTextCheckingResult in matches {
					// Link URL and link text is the same here, so just remember the link range. We don't need to modify the text
					let urlString = (remainingText as NSString).substring(with: match.range)
					links[ urlString ] = match.range
				}

				// Iterate all found links and attach
				for (urlString, range) in links {
					if let url = URL(string: urlString) {
						self.addLinkToURL(url: url, range: range)
					} else {
						NSLog("❌ Can't make URL from string: \(urlString)")
					}
				}
			}

			// Finally, set line height if necessary
			if lineHeight > 0 {
				let paragraphStyle = NSMutableParagraphStyle()
				paragraphStyle.lineSpacing = lineHeight
				paragraphStyle.alignment = textAlignment // Respect existing UILabel textAlignment
				let mutableAttrText = NSMutableAttributedString(attributedString: self.attributedText!)
				mutableAttrText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: mutableAttrText.length))
				super.attributedText = mutableAttrText
				self.setNeedsDisplay()
			}

			self.isUserInteractionEnabled = true

			// DEBUG: highlight all link areas
			if debugHighlightLinks {
				NSLog("ClickableLinkLabel: bounds: \(self.bounds), links: \(_links)")
				// Clear existing highlight views
				let views = subviews.filter { $0.tag == 554411 }
				for view in views {
					view.removeFromSuperview()
				}
				for link in _links {
					let frames = enclosingRectsForCharacterRange(link.range)
					for frame in frames {
						let view = UIView(frame: frame)
						view.tag = 554411
						view.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
						addSubview(view)
					}
				}
			}
		} catch {
			assertionFailure("Regex error: \(error)")
		}
	}

	/**
	Adds a link by setting the link attributes.
	Note that the attributes will be modified to match the font size if the .matchFontSizeForLinks property is true.
	*/
	fileprivate func addLinkToURL(url: URL, range: NSRange) {
		// If link style attributes are set, use those. Otherwise use current font plus underline
		var linkAttributes: [NSAttributedString.Key: Any]
		if let attributes = linkTextAttributes {
			linkAttributes = attributes
		} else {
			linkAttributes = [ NSAttributedString.Key.font: self.font as Any, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue ]
		}

		// swiftlint:disable:next force_cast_gp - Disable this rule because it was done before we added Swiftlint. -MACO
		let mutableAttributedString = self.attributedText!.mutableCopy() as! NSMutableAttributedString
		let result = NSTextCheckingResult.linkCheckingResult(range: range, url: url)
		mutableAttributedString.addAttributes(linkAttributes, range: result.range)
		super.attributedText = mutableAttributedString
		self.setNeedsDisplay()
		_links.append(result)
	}

	/**
	Adds a NSTextCheckingResult with a NSLinkAttributeName and a range.
	This is necessary so the _links array can be updated and the touch tracking can identify the link.
	*/
	open func addLinkTextCheckingResult(_ textCheckingResult: NSTextCheckingResult) {
		_links.append(textCheckingResult)
	}

	/**
	When touches ended, iterate all links to see if any was hit.
	If so, pass it on to the delegate.
	*/
	override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Get first touch and convert to local coordinates
		guard let touch = touches.first else { return }
		let touchPoint = touch.location(in: self)

		// Iterate links
		for linkTextCheckingResult in _links {
			// See if touched point intersects the link rect. A link might span several lines so iterate all enclosing rects.
			let linkRects = enclosingRectsForCharacterRange(linkTextCheckingResult.range)

			for linkRect in linkRects {
				if linkRect.contains(touchPoint) {
					// Yep, we clicked the link: inform the delegate
					self.linkDelegate?.clickedLinkWithURL(linkTextCheckingResult.url!)	// Explicitly unwrapped because we have only added links to the dictionary
					return	// Never mind any other links
				}
			}
		}

		super.touchesEnded(touches, with: event)
	}
}
