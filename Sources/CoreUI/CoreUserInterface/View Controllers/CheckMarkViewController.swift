//
//  CheckMarkViewController.swift
//  CoopM16
//
//  Created by Georgi Damyanov on 11/10/2017.
//  Copyright © 2017 Greener Pastures. All rights reserved.
//

import UIKit

open class CheckMarkViewController: UIViewController {
	private struct Constants {
		static let checkmarkAnimationDuration = 0.2
		static let automaticDismissTime: TimeInterval = 2
	}
	
	@IBOutlet weak var checkmarkAnimationView: CheckmarkSpinnerAnimationView!
	
	public var timer: Timer?
	
	/// Copmpletion handler to be executed after showing the checkmark
	public var completionHandler: (() -> Void)?
	
	override open func viewDidLoad() {
		super.viewDidLoad()
		checkmarkAnimationView.startSpinnerAnimation()
	}
	
	override open func viewDidAppear(_ animated: Bool ) {
		super.viewDidAppear( animated )
		checkmarkAnimationView.startCheckmarkAnimation()
		
		// Set a timer to automatically dismiss the view controller
		timer?.invalidate()
		timer = Timer.scheduledTimer( timeInterval: Constants.automaticDismissTime, target: self, selector: #selector( timerExpired ), userInfo: nil, repeats: true )
	}
	
	override open func viewWillDisappear( _ animated: Bool ) {
		super.viewWillDisappear( animated )
		
		// Invalidate and remove the timer
		timer?.invalidate()
		timer = nil
	}
	
	@objc open func timerExpired() {
		// If we have a completion handler call it, else just dismiss the view controller
		if let completionHandler = completionHandler {
			completionHandler()
		} else {
			dismiss( animated: true )
		}
	}
}
