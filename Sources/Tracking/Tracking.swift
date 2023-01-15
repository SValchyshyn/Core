//
//  Tracking.swift
//  Tracking
//
//  Created by Jens Willy Johannsen on 01/07/2016.
//  Copyright © 2016 Lobyco. All rights reserved.
//

import UIKit

/// App user authentication action to be handled by tracking providers
public enum TrackingAuthenticationState {
	case authenticated
	case loggedOut
}

/// Identifies element that requires tracking
public enum TrackingCategory {
	/// Screen implementing `Trackable` protocol
	case screenTrackable(screen: Trackable)

	/// Screen with tile
	case screen(title: String)

	/// Event with title
	case event(title: String)
}

/**
Class for all tracking/analytics.

Use `Tracking.shared` for all functions.

Specify configuration in `Config` class.
*/
public final class Tracking: NSObject {
	// MARK: - Singleton.

	/**
	Shared tracking instance.
	*/
	public static let shared = Tracking()
	
	private override init() {}
	
	// MARK: - Dependencies.

	/// Manager to enhance URL with tracking params.
	public var trackingURLProvider: TrackingURLProvider?
	
	// MARK: - Properties.
	
	/// Flag marking if tracking is enabled
	public var isEnabled: Bool = false
	
	/// Application name used in tracking reporting
	public var appName: String = ""
	
	private var trackingProviders: [TrackingProvider] = []
	
	/// Indication of whether tracking providers have been initialized
	public private(set) var isTrackingReady = false

	/// Set of `ExtraTrackingParametersProviders` that enrich the tracking experience.
	private var _parametersProviders: Set<AnyExtraTrackingParametersProvider> = .init()

	/// The provider for system related properties which are sent along with every request.
	private var _systemParametersProvider: ExtraTrackingParametersProvider?

	// MARK: - Public interface.

	/**
	Set the tracking providers and the system parameters provider.

	- parameter providers:	Array of objects conforming to the tracking protocol.
	- parameter systemParametersProvider: The provider of system properties send along with the tracking initialization and all other tracking events.
	*/
	public func setTrackingProviders( _ providers: [TrackingProvider], systemParametersProvider: ExtraTrackingParametersProvider? ) {
		guard isEnabled else { return }
		
		self.trackingProviders = providers

		// Remember the provider of system properties.
		_systemParametersProvider = systemParametersProvider
		let systemInfo = _systemParametersProvider?.parameters.parametersDict ?? [:]

		for provider in trackingProviders {
			provider.setup( with: systemInfo )
		}
		
		// Set indication that tracking providers have been initialized
		isTrackingReady = true
	}
	
	/**
	Registers the provider so it can be queried for extra parameters used to enrich the tracking process.
	Uniqueness of the providers is assured, passing along the same provider twice will have no effect.
	Will hold a **strong** reference to the provider

	- parameter parameterProviders: 		Providers of the extra, module specific, tracking parameters.
	*/
	public func register( _ parameterProviders: ExtraTrackingParametersProvider... ) {
		parameterProviders
			// Transform the concrete type into AnyExtraTrackingParametersProvider since it's a concrete type and we can store it into a Set
			.lazy.map { AnyExtraTrackingParametersProvider( $0 ) }
			// Insert the transformed values in the set.
			.forEach { _parametersProviders.insert( $0 ) }
	}

	/**
	Unregisters the provider from the Tracking enrichment process.

	- parameter parameterProvider:		Will stop being requested for `parameters` in the process of tracking.
	*/
	public func unregister( parameterProvider: ExtraTrackingParametersProvider ) {
		// Do we actually have the provider? Look into the `.provider` property since we're wrapping it.
		guard let index = _parametersProviders.firstIndex( where: { $0.provider.isEqual( parameterProvider ) } ) else { return }

		// Remove the provider found at that index.
		_parametersProviders.remove( at: index )
	}
	
	/**
	Track screen.
	 
	- parameter viewController:				View controller to track
	- parameter parameters:					Dictionary with extra parameters.
	- parameter includeExtraInfo:			`true` to include member info.
	*/
	public func trackViewController(_ viewController: Trackable, parameters: [String: String]?, includeExtraInfo: Bool) {
		track(.screenTrackable(screen: viewController), parameters: parameters, includeExtraInfo: includeExtraInfo)
	}
	
	/**
	Track screen.
	 
	- parameter viewController:				View controller to track
	- parameter parameters:					Parameter array with extra parameters.
	- parameter includeExtraInfo:			`true` to include member info.
	*/
	public func trackViewController(_ viewController: Trackable, parameters: [Parameter] = [], includeExtraInfo: Bool = true) {
		trackViewController(viewController, parameters: parameters.parametersDict, includeExtraInfo: includeExtraInfo)
	}

	/**
	Track view with the specified title.
	Call this function in view controllers' `viewDidAppear()`.
	
	- parameter title: 						Screen/view title.
	- parameter parameters: 				Dictionary with extra parameters.
	- parameter includeExtraInfo:    		`true` to include member info.
	*/
	public func trackView( title: String, parameters: [String: String]?, includeExtraInfo: Bool ) {
		track( .screen(title: title), parameters: parameters, includeExtraInfo: includeExtraInfo )
	}
	
	/**
	Track an event.
	
	- parameter event: 						Event title.
	- parameter parameters: 				Dictionary with extra parameters.
	- parameter includeExtraInfo:    		`true` to include extra info in the Tracking.
	*/
	public func trackEvent( event title: String, parameters: [String: String]?, includeExtraInfo: Bool ) {
		track( .event(title: title), parameters: parameters, includeExtraInfo: includeExtraInfo )
	}
	
	/// Track event.
	public func trackEvent(_ event: Event) {
		trackEvent(event: event.name.rawValue,
				   parameters: event.parameters.parametersDict,
				   includeExtraInfo: event.includeExtraInfo)
	}
	
	/// Track event.
	public func trackEvent(name: Event.Name, parameters: [Parameter] = [], includeExtraInfo: Bool = true) {
		trackEvent(.init(name: name, parameters: parameters, includeExtraInfo: includeExtraInfo))
	}

	/**
	Performs tracking on the provided category.

	- parameter title: 						Screen/ view title or event title.
	- parameter parameters: 				Dictionary with extra parameters.
	- parameter includeExtraInfo:    		`true` to include member info.
	*/
	private func track( _ category: TrackingCategory, parameters: [String: String]?, includeExtraInfo: Bool ) {
		// Initialize data sources from parameters or as empty dictionary
		var dataSources: [String: String] = parameters ?? [:]

		// Add the system info. If a key is already present we keep the original value
		let systemInfo = _systemParametersProvider?.parameters.parametersDict ?? [:]
		dataSources = dataSources.merging( systemInfo ) { current, _ in current }

		// Include personal member data if specified.
		if includeExtraInfo { addExtraInfo( to: &dataSources ) }

		for provider in trackingProviders {
			provider.track( category, parameters: dataSources, includeExtraInfo: includeExtraInfo )
		}
	}

	/**
	Update the Adobe UUID and the current authentication state on tracking providers.
	*/
	public func syncTrackingID( for authenticationState: TrackingAuthenticationState ) {
		for provider in trackingProviders {
			provider.syncTrackingID( for: authenticationState )
		}
	}

	/**
	Set the advertising identifier for the apps
	*/
	public func setAdvertisingIdentifier(_ IDFA: String?) {
		trackingProviders.forEach{ $0.setAdvertisingIdentifier( IDFA )}
	}

	// MARK: - Utils.

	/**
	Enriches the tracking data source with information about the member.

	- parameter trackingDictionary:			Where the new key-value pairs that contain member information should be added.
	*/
	private func addExtraInfo( to trackingDictionary: inout [String: String] ) {
		// Enrich the tracking from the providers.
		// Merge the two dictionaries, overriding any value given by the provided.
		_parametersProviders.forEach { trackingDictionary.merge( $0.parameters.parametersDict, uniquingKeysWith: { _, new in new } ) }
	}
}

extension Tracking: TrackingURLProvider {
	public func appendTrackingToURL( url: URL, completion: @escaping (_ url: URL ) -> Void ) {
		guard let trackingURLProvider = trackingURLProvider else {
			completion(url)
			return
		}

		// Delegate the job.
		trackingURLProvider.appendTrackingToURL( url: url, completion: completion )
	}
}
