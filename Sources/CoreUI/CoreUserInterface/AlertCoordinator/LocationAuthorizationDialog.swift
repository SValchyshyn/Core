//
//  LocationAuthorizationDialog.swift
//  CoopUI
//
//  Created by Andriy Tkach on 3/11/21.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import UIKit
import CoreLocation

public class LocationAuthorizationDialog: NSObject, AlertRepresenting, CLLocationManagerDelegate {
	private var locationManager: CLLocationManager
	private var dismissCallback: (() -> Void)?
	public var completionCallback: (() -> Void)?
	
	public override init() {
		self.locationManager = CLLocationManager()
		super.init()
		
		self.locationManager.delegate = self
	}
	
	public func present(overViewController: UIViewController, didDismiss: @escaping () -> Void) {
		dismissCallback = didDismiss
		locationManager.requestWhenInUseAuthorization()
	}
	
	public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		// Don't close alert until user doen't make a choice about location permissions
		guard status != .notDetermined else {
			return
		}
		
		dismissCallback?()
		completionCallback?()
	}
	 
	public func isEqualTo(_ otherAlert: AlertRepresenting) -> Bool {
		// Treat all LocationAuthorizationDialog as equal
		return otherAlert is LocationAuthorizationDialog
	}
}
