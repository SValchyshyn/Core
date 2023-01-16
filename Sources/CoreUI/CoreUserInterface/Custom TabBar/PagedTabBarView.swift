//
//  PagedTabBarView.swift
//  CoreUserInterface
//
//  Created by Andriy Tkach on 1/25/21.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import UIKit
import Core

public protocol PagedTabBarViewDataSource: AnyObject {
	func numberOfItems(in pagedTabBarView: PagedTabBarView) -> Int
	func pagedTabBarView(_ pagedTabBarView: PagedTabBarView, titleForItemAt index: Int) -> String
}

public protocol PagedTabBarViewDelegate: AnyObject {
	func pagedTabBarView(_ pagedTabBarView: PagedTabBarView, didSelectItemAt index: Int)
}

public enum PagedTabBarViewBehaviour {
	// Tab bar items have the same width (tab-bar-view-width/items-count) and fit tab bar view width
	case fixedWidth
	
	// Width of tab bar items depend on title length and they are scrollable in tab bar view
	case scrollable
}

public class PagedTabBarView: UIView {
	
	private enum Constants {
		static let dividerHeight: CGFloat = 1.0
		static let selectAnimationDuration: TimeInterval = 0.3
	}
	
	// MARK: - Private UI elements
	
	private let scrollView = UIScrollView()
	private let contentStackView = UIStackView()
	private let dividerView = UIView()
	private let indicatorView = UIView()
	
	// MARK: - Private vars
	
	private var indicatorConstraints: [NSLayoutConstraint] = []
	private var behaviourConstraints: [NSLayoutConstraint] = []
	
	private var tabBarItems: [PagedTabBarItemView] {
		contentStackView.arrangedSubviews.compactMap { $0 as? PagedTabBarItemView }
	}
	
	// MARK: - Public vars
	
	public weak var dataSource: PagedTabBarViewDataSource?
	public weak var delegate: PagedTabBarViewDelegate?
	
	public var indicatorColor: UIColor? {
		didSet { indicatorView.backgroundColor = indicatorColor }
	}
	
	public var textNormalColor: UIColor? {
		didSet {
			tabBarItems.forEach {
				$0.titleNormalColor = textNormalColor
			}
		}
	}
	
	public var textSelectedColor: UIColor? {
		didSet {
			tabBarItems.forEach {
				$0.titleSelectedColor = textSelectedColor
			}
		}
	}
	
	public var textFont: UIFont? {
		didSet {
			tabBarItems.forEach {
				$0.titleFont = textFont
			}
		}
	}
	
	public var behaviour: PagedTabBarViewBehaviour = .fixedWidth {
		didSet {
			updateBehaviour()
		}
	}
	
	public var selectedIndex: Int = 0 {
		didSet {
			updateItemStates()
		}
	}
	
	// MARK: Public override inits
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		privateInit()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		privateInit()
	}

	// MARK: - Private
	
	private func privateInit() {
		backgroundColor = colorsContent.colorSurface
		
		// Setup scroll view to make possibility of scrollable paged tab bar
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsHorizontalScrollIndicator = false
		addSubview(scrollView)
		scrollView.pinEdges(to: self)
		
		// Setup stack view to keep paged tab bar items
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.axis = .horizontal
		scrollView.addSubview(contentStackView)
		
		// Indicator view of selected item
		indicatorView.translatesAutoresizingMaskIntoConstraints = false
		indicatorView.backgroundColor = colorsContent.primaryColor
		addSubview(indicatorView)
		
		// Bottom divider view
		dividerView.translatesAutoresizingMaskIntoConstraints = false
		dividerView.backgroundColor = colorsContent.dividerColor
		addSubview(dividerView)
		
		// UI layout logic is next:
		// - Scroll view keeps stack view with paged tab bar items
		// - Stack view placed above divider view
		// - Indicator view position is changed depending on selected item
		NSLayoutConstraint.activate([
			dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
			dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
			contentStackView.topAnchor.constraint(equalTo: topAnchor),
			contentStackView.bottomAnchor.constraint(equalTo: dividerView.topAnchor)
		])

		// Set the maximum non-required priority for the divider height constraint,
		// to be able to hide `PagedTabBarView` by setting its height constraint to 0
		let dividerViewHeightConstraint = dividerView.heightAnchor.constraint(equalToConstant: Constants.dividerHeight)
		dividerViewHeightConstraint.priority = UILayoutPriority.required - 1
		dividerViewHeightConstraint.isActive = true
		
		updateBehaviour()
	}
	
	private func updateBehaviour() {
		NSLayoutConstraint.deactivate(behaviourConstraints)
		
		switch behaviour {
		case .fixedWidth:
			contentStackView.distribution = .fillEqually
			behaviourConstraints = [
				contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
				contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor)
			]
			
		case .scrollable:
			contentStackView.distribution = .fill
			behaviourConstraints = [
				contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
				contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
			]
		}
		
		NSLayoutConstraint.activate(behaviourConstraints)
	}
	
	private func updateItemStates(animated: Bool = true) {
		tabBarItems.enumerated().forEach { index, pagedTabBarItem in
			// Update selection state
			pagedTabBarItem.isSelected = index == selectedIndex
			
			// Update position of indicator view for selected item
			if index == selectedIndex {
				// Calculate center position depending on current posistion
				let itemFrame = pagedTabBarItem.frame
				let scrollViewFrame = scrollView.frame
				let contentSize = scrollView.contentSize
				
				let offsetX: CGFloat
				if itemFrame.maxX + scrollViewFrame.midX >= contentSize.width {
					offsetX = max(0, contentSize.width - scrollViewFrame.width)
				} else {
					offsetX = max(0, itemFrame.midX - scrollViewFrame.midX)
				}
				
				let contentOffset = CGPoint(x: offsetX, y: 0)
				
				let updateOffset = {
					self.scrollView.contentOffset = contentOffset
					self.updateIndicatorView(for: pagedTabBarItem)
					self.layoutIfNeeded()
				}
				
				// Update position and selected indicator view
				if animated {
					UIView.animate(withDuration: Constants.selectAnimationDuration, animations: updateOffset)
				} else {
					updateOffset()
				}
			}
		}
	}
	
	private func updateIndicatorView(for tabBarItem: PagedTabBarItemView) {
		NSLayoutConstraint.deactivate(indicatorConstraints)
		
		let constraints = [
			tabBarItem.indicatorLayoutGuide.leftAnchor.constraint(equalTo: indicatorView.leftAnchor),
			tabBarItem.indicatorLayoutGuide.rightAnchor.constraint(equalTo: indicatorView.rightAnchor),
			tabBarItem.indicatorLayoutGuide.topAnchor.constraint(equalTo: indicatorView.topAnchor),
			tabBarItem.indicatorLayoutGuide.bottomAnchor.constraint(equalTo: indicatorView.bottomAnchor)
		]
		
		NSLayoutConstraint.activate(constraints)
		
		indicatorConstraints = constraints
	}
	
	private func insertItemToContentStackView(title: String, at index: Int) {
		let pagedTabBarItemView = PagedTabBarItemView(with: title)
		pagedTabBarItemView.translatesAutoresizingMaskIntoConstraints = false
		pagedTabBarItemView.tapAction = { [weak self] tapTabBarItem in
			guard let self = self, let tapIndex = self.tabBarItems.firstIndex(of: tapTabBarItem) else {
				return
			}
			
			self.selectedIndex = tapIndex
			self.delegate?.pagedTabBarView(self, didSelectItemAt: tapIndex)
		}
		pagedTabBarItemView.titleNormalColor = textNormalColor
		pagedTabBarItemView.titleSelectedColor = textSelectedColor
		pagedTabBarItemView.titleFont = textFont
		
		contentStackView.insertArrangedSubview(pagedTabBarItemView, at: index)
	}
	
	private func changeSelectedIndex(to tabBarItem: PagedTabBarItemView) {
		// If we can't get new selected index than selected item was removed
		// Selected index should remain but state of new slected item should be updated
		guard let newSelectedIndex = tabBarItems.firstIndex(of: tabBarItem) else {
			// Update selectedIndex if last item was removed
			if selectedIndex == tabBarItems.count {
				selectedIndex = tabBarItems.count - 1
			}
			
			// Update selected indicator and state for `selectedIndex` item
			guard let selectedTabBarItem = tabBarItems[safe: selectedIndex] else {
				return
			}
			selectedTabBarItem.isSelected = true
			updateIndicatorView(for: selectedTabBarItem)
			return
		}
		
		// Set new `selectedIndex`
		selectedIndex = newSelectedIndex
	}
	
	// MARK: - Public
	
	public func reloadTabBar() {
		guard let dataSource = dataSource else {
			return
		}
		
		// Clear previous items of proper type
		contentStackView.removeAllArrangedSubviews(of: PagedTabBarItemView.self)

		// Build paged tab bar view with new items from dataSource
		for i in 0..<dataSource.numberOfItems(in: self) {
			insertItemToContentStackView(title: dataSource.pagedTabBarView(self, titleForItemAt: i), at: i)
		}
		
		// Update state of selected item in paged tab bar view
		updateItemStates(animated: false)
	}
	
	public func insertItem(title: String, at index: Int) {
		// Insert operation should be allowed where index in range [0, tabBarItems.endIndex]
		guard index >= 0 && index <= tabBarItems.endIndex else {
			return
		}
		
		// Remember `currentItem` before insert to update `selectedIndex` later
		guard let currentItem = tabBarItems[safe: selectedIndex] else {
			return
		}
		
		insertItemToContentStackView(title: title, at: index)
		
		changeSelectedIndex(to: currentItem)
	}
	
	public func remove(at index: Int) {
		guard let tabBarItemView = tabBarItems[safe: index] else {
			return
		}
		
		// Remember `currentItem` before remove to update `selectedIndex` later
		guard let currentItem = tabBarItems[safe: selectedIndex] else {
			return
		}
		
		tabBarItemView.removeFromSuperview()
		
		changeSelectedIndex(to: currentItem)
	}
	
	public func updateTabBarItem(title: String, at index: Int) {
		tabBarItems[safe: index]?.title = title
	}
}
