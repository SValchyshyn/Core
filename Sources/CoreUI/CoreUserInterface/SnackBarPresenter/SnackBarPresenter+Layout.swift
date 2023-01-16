//
//  SnackBarPresenter+Layout.swift
//  CoreUserInterface
//
//  Created by Olexandr Belozierov on 01.08.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit

extension SnackBarPresenter {
	
	/// Layout for snack bar in superview
	public struct Layout {
		
		public typealias Layout = (SnackBar) -> Void
		
		private let layout: Layout
		
		public init(layout: @escaping Layout) {
			self.layout = layout
		}
		
		func configureLayout(for snackBar: SnackBar) {
			layout(snackBar)
		}
		
	}
	
}

public extension SnackBarPresenter.Layout {
	
	/// Default layout to show snack bar at the top of superview.
	static func atTop(of view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, topInset: CGFloat = 20, sideInset: CGFloat = 16) -> Self {
		verticalLayout(view: view, sideInset: sideInset) { snackBar in
			let topAnchor = topAnchor ?? view.safeAreaLayoutGuide.topAnchor
			return snackBar.topAnchor.constraint(equalTo: topAnchor, constant: topInset)
		}
	}
	
	/// Default layout to show snack bar at the bottom of superview.
	static func atBottom(of view: UIView, bottomAnchor: NSLayoutYAxisAnchor? = nil, bottomInset: CGFloat = 20, sideInset: CGFloat = 16) -> Self {
		verticalLayout(view: view, sideInset: sideInset) { snackBar in
			let bottomAnchor = bottomAnchor ?? view.safeAreaLayoutGuide.bottomAnchor
			return snackBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomInset)
		}
	}
	
	private static func verticalLayout(view: UIView, sideInset: CGFloat, verticalConstraint: @escaping (SnackBar) -> NSLayoutConstraint) -> Self {
		Self { snackBar in
			view.addSubview(snackBar)
			snackBar.translatesAutoresizingMaskIntoConstraints = false
			
			NSLayoutConstraint.activate([
				snackBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: sideInset),
				snackBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -sideInset),
				verticalConstraint(snackBar)])
		}
	}
	
}
