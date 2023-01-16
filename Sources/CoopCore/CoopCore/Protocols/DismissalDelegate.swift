//
//  DismissalDelegate.swift
//  CoopCore
//
//  Created by Roxana-Madalina Sturzu on 16/03/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

/**
Along with iOS 13, there are some changes on how the appearing methods are called when pages are presented over.
This delegate should solve that problem by being notified whenever the presented class is dismissed.
*/
public protocol DismissalDelegate: AnyObject {
	/**
	Called when the presented ViewController is about to be dismissed.
	*/
	func willBeginDismissal()

	/**
	Called after the presented ViewController was dismissed.
	*/
	func didEndDismissal()
}
