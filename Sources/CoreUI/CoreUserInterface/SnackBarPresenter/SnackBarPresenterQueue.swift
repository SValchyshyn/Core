//
//  SnackBarPresenterQueue.swift
//  CoreUserInterface
//
//  Created by Olexandr Belozierov on 01.08.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit
import Combine

/// Queue for presenting snack bars
public class SnackBarPresenterQueue {
	
	public static let shared = SnackBarPresenterQueue()
	
	private var currentPresenter: SnackBarPresenterBox?
	private var nextPresenter: SnackBarPresenterBox?
	
	public init() {}
	
	/// Adds presenter to queue
	public func add<SnackBar: UIView>(presenter: SnackBarPresenter<SnackBar>) {
		nextPresenter = _SnackBarPresenterBox(presenter: presenter, hideCompletion: startNextPresenter)
		currentPresenter?.hide() ?? startNextPresenter()
	}
	
	private func startNextPresenter() {
		currentPresenter = nextPresenter
		nextPresenter = nil
		currentPresenter?.show()
	}
	
}

/// Type eraser for `SnackBarPresenter`
private protocol SnackBarPresenterBox {
	
	func show()
	func hide()
	
}

private struct _SnackBarPresenterBox<SnackBar: UIView>: SnackBarPresenterBox {
	
	private let presenter: SnackBarPresenter<SnackBar>
	private let hideEventSubscription: AnyCancellable
	
	init(presenter: SnackBarPresenter<SnackBar>, hideCompletion: @escaping () -> Void) {
		self.presenter = presenter
		
		hideEventSubscription = presenter.events.sink { event in
			guard case .didDisappear = event else { return }
			hideCompletion()
		}
	}
	
	func show() {
		presenter.show()
	}
	
	func hide() {
		presenter.hide()
	}
	
}
