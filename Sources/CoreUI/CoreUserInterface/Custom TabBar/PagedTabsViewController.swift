//
//  PagedTabsViewController.swift
//  CoreUserInterface
//
//  Created by Andriy Tkach on 2/1/21.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import UIKit

public protocol PagedTabsViewControllerDelegate: AnyObject {
	func pagedTabsViewController(_ pagedTabsViewController: PagedTabsViewController, didSelectPageAt index: Int)
}

// swiftlint:disable type_body_length
open class PagedTabsViewController: UIViewController {
	
	private enum Constants {
		static let tabBarHeight: CGFloat = 48.0
	}
	
	// MARK: - Public UI elements
	
	public let topBarView = TopBarView()
	public let pagedTabBarView = PagedTabBarView()
	
	// MARK: - Private UI elements
	
	private let pagesScrollView = UIScrollView()
	private let pagesStackView = UIStackView()
	
	// MARK: - Private

	/// We use this constraint to modify if the tabs view should leave space for the tab bar
	private var pagedTabBarTopConstraint = NSLayoutConstraint()
	
	private var pagesStackViewHeightConstraint = NSLayoutConstraint()
	private var pagedTabBarHeightConstraint = NSLayoutConstraint()
	
	// Calculate page index in scroll view based on current offset
	private var scrollViewPageIndex: Int {
		let pageWidth = pagesScrollView.bounds.size.width
		let pageOffset = pagesScrollView.contentOffset.x
		
		return Int(round(pageOffset / pageWidth))
	}
	
	// Uses to prevent reloading of viewControllers during insert/remove operations
	private var shouldReloadViewControllers: Bool = true
	
	// Indicate index of selected tab
	private var tabSelectedIndex: Int = 0
	
	// Uses to prevent handling scrollViewDidScroll events if user manually taps (not swipe) to select a tab
	private var scrollTransitionAfterManualSelect: Bool = false
	
	// MARK: - Public
	
	public weak var delegate: PagedTabsViewControllerDelegate?
	
	// Define behaviour of tab bar view
	public var pagedTabBarViewBehaviour: PagedTabBarViewBehaviour = .fixedWidth {
		didSet {
			pagedTabBarView.behaviour = pagedTabBarViewBehaviour
		}
	}
	
	// Public property to change selected index of tab
	public var selectedIndex: Int {
		get { tabSelectedIndex }
		
		set {
			selectPageAtIndex(index: newValue, shouldUpdateContentOffset: true)
			tabSelectedIndex = newValue
		}
	}

	/// Used to define if the paged scroll view has a bouncing effect.
	public var shouldBounce: Bool {
		get { pagesScrollView.bounces }
		set { pagesScrollView.bounces = newValue }
	}
	
	/// Flag for respecting the bottom safe area.
	public var shouldRespectBottomSafeArea: Bool = false
	
	// Return current selected view controller
	open var currentViewController: UIViewController? {
		viewControllers[safe: tabSelectedIndex]
	}
	
	// Return maxY value of pagedTabBarView
	public var pagedTabBarViewMaxY: CGFloat { pagedTabBarView.frame.maxY }
	
	// Set bottom content inset for pagesScrollView
	public var bottomContentViewPadding: CGFloat = 0.0 {
		didSet {
			guard isViewLoaded, bottomContentViewPadding != oldValue else { return }
			
			// Height of inner stack view should be aligned with scroll view inset paddings
			// It prevents vertical scrolling of stack view inside scroll view
			pagesScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomContentViewPadding, right: 0)
			pagesStackViewHeightConstraint.constant = -bottomContentViewPadding
		}
	}

	public var isTabBarHidden = false {
		didSet {
			guard isViewLoaded, isTabBarHidden != oldValue else { return }

			// Toggle the visibility of `PagedTabBarView` by setting its height constraint to 0 or default height
			pagedTabBarHeightConstraint.constant = isTabBarHidden ? 0 : Constants.tabBarHeight
			pagedTabBarView.isHidden = isTabBarHidden
		}
	}

	// Array of tab views controllers
	public var viewControllers: [UIViewController] = [] {
		didSet {
			reloadData()
		}
	}

	/// Show or hide the top bar view
	public var isTopBarHidden: Bool = false {
		didSet {
			guard isViewLoaded && oldValue != isTopBarHidden else {
				return
			}

			// Hide or show the top bar
			pagedTabBarTopConstraint.isActive = false
			pagedTabBarTopConstraint = pagedTabBarView.topAnchor.constraint(equalTo: isTopBarHidden ? view.topAnchor : topBarView.bottomAnchor)
			pagedTabBarTopConstraint.isActive = true
			topBarView.isHidden = isTopBarHidden
		}
	}
	
	// Set color of top bar
	public var topBarColor: UIColor? {
		didSet {
			topBarView.showImage = false
			topBarView.backgroundColor = topBarColor
		}
	}
	
	// Set top bar close button visibility
	public var showTopBarCloseButton: Bool = false {
		didSet {
			topBarView.showCloseButton = showTopBarCloseButton
		}
	}
	
	// Set top bar left button visibility
	public var showTopBarLeftButton: Bool = false {
		didSet {
			topBarView.showLeftButton = showTopBarLeftButton
		}
	}
	
	// Set title of TopBarView
	public var topBarTitle: String? {
		didSet {
			topBarView.title = topBarTitle
		}
	}
	
	// Selection indicator (bottom underline bar) color
	public var tabBarIndicatorColor: UIColor? {
		didSet { pagedTabBarView.indicatorColor = tabBarIndicatorColor }
	}
	
	// Tab title normal color
	public var tabBarTextNormalColor: UIColor? {
		didSet { pagedTabBarView.textNormalColor = tabBarTextNormalColor }
	}
	
	// Tab title selected color
	public var tabBarTextSelectedColor: UIColor? {
		didSet { pagedTabBarView.textSelectedColor = tabBarTextSelectedColor }
	}
	
	// Tab title font
	public var tabBarTextFont: UIFont? {
		didSet { pagedTabBarView.textFont = tabBarTextFont }
	}
	
	// Define how view controller should be closed/dismissed
	public var closeAction: (() -> Void)?
	
	// MARK: - ViewController lifecycle
	
	public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
		return false
	}
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		configureUI()
		
		reloadData()
	}
	
	// Notify current view controller about `viewWillAppear`
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		currentViewController?.beginAppearanceTransition(true, animated: animated)
	}
	
	// Notify current view controller about `viewDidAppear`
	open override func viewDidAppear( _ animated: Bool ) {
		super.viewDidAppear( animated )
		
		currentViewController?.endAppearanceTransition()
	}
	
	// Make sure to select proper tab after view has finished layouting
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if scrollViewPageIndex != tabSelectedIndex {
			selectPageAtIndex(index: tabSelectedIndex, shouldUpdateContentOffset: true)
		}
	}
	
	// MARK: Public interface
	
	public func reloadData() {
		guard isViewLoaded, shouldReloadViewControllers else {
			return
		}
		
		reloadViewControllers()
		
		pagedTabBarView.reloadTabBar()
	}
	
	// MARK: Public
	
	public func setLeftTopBarButtonOverride( _ button: UIButton, size: CGSize ) {
		topBarView.setLeftButtonOverride(button, size: size)
	}

	public func setLeftTopBarButtonOverride(with icon: UIImage?, target: AnyObject, action: Selector) {
		topBarView.leftButtonIcon = icon
		topBarView.addBackButtonTarget(target, action: action)
	}
	
	public func insert(viewController: UIViewController, at index: Int) {
		// Insert operation should be allowed where index in range [0, viewControllers.endIndex]
		guard index >= 0 && index <= viewControllers.endIndex else {
			return
		}
		
		// Remember `currentViewController` before insert to update `selectedIndex` later
		guard let currentViewController = currentViewController else {
			return
		}
		
		// Add view controller to array and stack view
		shouldReloadViewControllers = false
		viewControllers.insert(viewController, at: index)
		insertToPagesStackView(viewController: viewController, at: index)
		pagedTabBarView.insertItem(title: viewController.title?.uppercased() ?? "", at: index)
		shouldReloadViewControllers = true
		
		changeSelectedIndex(to: currentViewController)
	}
	
	public func removeFromTabs(viewController: UIViewController) {
		guard let index = viewControllers.firstIndex(of: viewController) else {
			return
		}
		
		// Remember `currentViewController` before remove to update `selectedIndex` later
		guard let currentViewController = currentViewController else {
			return
		}
		
		// Send proper appearance event to notify that current view controller is going to be invisible
		if index == selectedIndex {
			currentViewController.beginAppearanceTransition(false, animated: true)
			currentViewController.endAppearanceTransition()
		}

		// Remove view controller from array and stack view
		shouldReloadViewControllers = false
		viewControllers.removeAll { $0 == viewController }
		remove(viewController: viewController)
		pagedTabBarView.remove(at: index)
		shouldReloadViewControllers = true
		
		changeSelectedIndex(to: currentViewController)
	}
	
	public func updateTab(title: String, at index: Int) {
		pagedTabBarView.updateTabBarItem(title: title, at: index)
	}
	
	// MARK: Private
	
	private func configureUI() {
		view.backgroundColor = colorsContent.colorBackground
		
		// Setup navigation top bar view
		topBarView.translatesAutoresizingMaskIntoConstraints = false
		topBarView.title = topBarTitle
		topBarView.useDarkElements = false
		topBarView.showImage = true
		topBarView.addCloseButtonTarget(self, action: #selector(closeAction(_:)))
		view.addSubview(topBarView)

		// Setup paged tab bar view
		pagedTabBarView.translatesAutoresizingMaskIntoConstraints = false
		pagedTabBarView.dataSource = self
		pagedTabBarView.delegate = self
		pagedTabBarView.selectedIndex = tabSelectedIndex
		view.addSubview(pagedTabBarView)
		
		// Setup page scroll view
		pagesScrollView.translatesAutoresizingMaskIntoConstraints = false
		pagesScrollView.showsHorizontalScrollIndicator = false
		pagesScrollView.isPagingEnabled = true
		pagesScrollView.delegate = self
		view.addSubview(pagesScrollView)
		
		// Add pages stack view in scroll view
		pagesStackView.translatesAutoresizingMaskIntoConstraints = false
		pagesStackView.axis = .horizontal
		pagesScrollView.addSubview(pagesStackView)
		pagesStackView.pinEdges(to: pagesScrollView)
		
		// UI layout logic is built from top to bottom:
		// - Top bar with title, left accessory button and right close button
		// - Paged tab bar with tab bar items
		// - Scroll view with stack view which keeps views of `viewControllers`
		
		var constraintBottom = pagesScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		if shouldRespectBottomSafeArea {
			constraintBottom = pagesScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		}
		
		NSLayoutConstraint.activate([
			topBarView.topAnchor.constraint(equalTo: view.topAnchor),
			topBarView.leftAnchor.constraint(equalTo: view.leftAnchor),
			topBarView.rightAnchor.constraint(equalTo: view.rightAnchor),
			pagedTabBarView.leftAnchor.constraint(equalTo: view.leftAnchor),
			pagedTabBarView.rightAnchor.constraint(equalTo: view.rightAnchor),
			pagesScrollView.topAnchor.constraint(equalTo: pagedTabBarView.bottomAnchor),
			pagesScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
			pagesScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
			constraintBottom
		])

		pagesStackViewHeightConstraint = pagesStackView.heightAnchor.constraint(equalTo: pagesScrollView.heightAnchor)
		pagesStackViewHeightConstraint.isActive = true

		// Hide or show the top bar view depending on the flag
		pagedTabBarTopConstraint = pagedTabBarView.topAnchor.constraint(equalTo: isTopBarHidden ? view.topAnchor : topBarView.bottomAnchor)
		pagedTabBarTopConstraint.isActive = true

		pagedTabBarHeightConstraint = pagedTabBarView.heightAnchor.constraint(equalToConstant: Constants.tabBarHeight)
		pagedTabBarHeightConstraint.isActive = true
	}
	
	private func reloadViewControllers() {
		pagesStackView.removeAllArrangedSubviews(of: UIView.self)
		
		viewControllers.enumerated().forEach { index, viewController in
			insertToPagesStackView(viewController: viewController, at: index)
		}
	}
	
	private func insertToPagesStackView(viewController: UIViewController, at index: Int) {
		viewController.willMove(toParent: self)

		viewController.view.translatesAutoresizingMaskIntoConstraints = false
		pagesStackView.insertArrangedSubview(viewController.view, at: index)
		viewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

		addChild(viewController)
		viewController.didMove(toParent: self)
	}
	
	private func selectPageAtIndex(index: Int, shouldUpdateContentOffset: Bool = true, animated: Bool = false) {
		guard isViewLoaded,
			  let nextViewController = viewControllers[safe: index],
			  let currentViewController = currentViewController else {
			return
		}
		
		let hasIndexChanged = index != tabSelectedIndex

		// Send proper appearence calls to current/next view controller
		if hasIndexChanged {
			sendAppearanceUpdates(currentViewController: currentViewController,
								  nextViewController: nextViewController)
		}

		pagedTabBarView.selectedIndex = index
		tabSelectedIndex = index

		// Notify delegate about page change
		delegate?.pagedTabsViewController(self, didSelectPageAt: tabSelectedIndex)
		
		guard shouldUpdateContentOffset else {
			return
		}
		
		let pageWidth = Int(pagesScrollView.bounds.size.width)
		let pageOffset = CGPoint(x: index * pageWidth, y: 0)
		
		if animated, hasIndexChanged {
			scrollTransitionAfterManualSelect = true
		}
		
		pagesScrollView.setContentOffset(pageOffset, animated: animated)
	}
	
	private func sendAppearanceUpdates(currentViewController: UIViewController?, nextViewController: UIViewController) {
		// Prevent sending appearance events if view is not visible
		guard view.window != nil else { return }
		
		currentViewController?.beginAppearanceTransition(false, animated: true)
		nextViewController.beginAppearanceTransition(true, animated: true)
		currentViewController?.endAppearanceTransition()
		nextViewController.endAppearanceTransition()
	}
	
	private func changeSelectedIndex(to viewController: UIViewController) {
		// If we can't get new selected index than selected view controller was removed
		// Selected index should remain but appearence updates should be sent to new visible view controller
		guard let newSelectedIndex = viewControllers.firstIndex(of: viewController) else {
			// Set selectedIndex to last position if last selected viewController was removed
			if selectedIndex == viewControllers.count {
				selectedIndex = viewControllers.count - 1
			}
			
			// Send appearence update to new visible view controller
			guard let nextViewController = viewControllers[safe: selectedIndex] else {
				return
			}
			sendAppearanceUpdates(currentViewController: nil, nextViewController: nextViewController)
			
			return
		}
		
		// Set new `selectedIndex`
		selectedIndex = newSelectedIndex
	}
	
	// MARK: - Actions
	
	@IBAction func closeAction(_ sender: AnyObject) {
		closeAction?()
	}
}

extension PagedTabsViewController: PagedTabBarViewDataSource {
	public func numberOfItems(in pagedTabBarView: PagedTabBarView) -> Int {
		return viewControllers.count
	}
	
	public func pagedTabBarView(_ pagedTabBarView: PagedTabBarView, titleForItemAt index: Int) -> String {
		return viewControllers[index].title?.uppercased() ?? ""
	}
}

extension PagedTabsViewController: PagedTabBarViewDelegate {
	public func pagedTabBarView(_ pagedTabBarView: PagedTabBarView, didSelectItemAt index: Int) {
		selectPageAtIndex(index: index, shouldUpdateContentOffset: true, animated: true)
	}
}

extension PagedTabsViewController: UIScrollViewDelegate {
	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		scrollTransitionAfterManualSelect = false
	}
	
	public func scrollViewDidScroll( _ scrollView: UIScrollView ) {
		guard !scrollTransitionAfterManualSelect else {
			return
		}
		
		if scrollViewPageIndex != tabSelectedIndex {
			selectPageAtIndex(index: scrollViewPageIndex, shouldUpdateContentOffset: false)
		}
	}
}
