//
//  CloseWebAuthFlowRoute.swift
//  Authentication
//
//  Created by Olexandr Belozierov on 19.05.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit
import AuthenticationDomain

actor CloseWebAuthFlowRoute {
	
	typealias Completion = (Result<AuthToken, Error>) -> Void
	
	private weak var viewController: UIViewController?
	private var completion: Completion?
	
	init(viewController: UIViewController, completion: @escaping Completion) {
		self.viewController = viewController
		self.completion = completion
	}
	
	nonisolated func close(with result: Result<AuthToken, Error>) {
		Task { await complete(with: result) }
	}
	
	private func complete(with result: Result<AuthToken, Error>) async {
		if let viewController = viewController {
			await dismiss(viewController)
		}
		
		if let completion = completion {
			self.completion = nil // Remove completion to avoid multiple calls
			completion(result)
		}
	}
	
	private func dismiss(_ viewController: UIViewController) async {
		await withCheckedContinuation { continuation in
			Task { @MainActor in
				viewController.dismiss(animated: true, completion: continuation.resume)
			}
		}
	}
	
	deinit {
		// Make sure that completion was called
		completion?(.failure(AuthManagerError.cancelledByUser))
	}
	
}
