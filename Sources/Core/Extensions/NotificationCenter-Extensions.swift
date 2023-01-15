//
//  NotificationCenter-Extensions.swift
//  CoopUI
//
//  Created by Georgi Damyanov on 08/02/2021.
//  Copyright © 2021 Greener Pastures. All rights reserved.
//

import Foundation

public extension NotificationCenter {
	/**
	Observe the given notification until a single notification is received. Aftewards the observer is removed.
	*/
	func observeOnce(for name: Notification.Name, object: Any? = nil, queue: OperationQueue? = nil, observer: @escaping (Notification) -> Void) {
		var token: NSObjectProtocol?
		token = addObserver(forName: name, object: object, queue: queue) { notification in
			observer(notification)
			token.map(self.removeObserver)
		}
	}

	/**
	Observe the given notification until a single notification is received. Aftewards the observer is removed.
	*/
	func observeOnce(for name: Notification.Name, object: Any? = nil, queue: OperationQueue? = nil, observer: @escaping () -> Void) {
		observeOnce(for: name, object: object, queue: queue) { _ in observer() }
	}
}
