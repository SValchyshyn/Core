//
//  EventDispatcher.swift
//  CoopCore
//
//  Created by Ievgen Goloboiar on 31.08.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

/// Generic class to dispatch events instead of multiple-delegate approach.
/// `Listener` should be class-protocol, `Event` can be some enum.
/// In this way we can have some simple event bus (ideally it should be singleton) and enum-based event instead of string-based notifications.
public class EventDispatcher<Listener, Event> {
	/// Hash table of all listeners.
	fileprivate(set) public var listeners = NSHashTable<AnyObject>.weakObjects()

	// MARK: - Public
	
	/// Add listener.
	/// - Parameter listener: `Listener` object.
	public func addListener( _ listener: Listener ) {
		listeners.add( listener as AnyObject )
	}
	
	/// Remove listener.
	/// - Parameter listener: `Listener` object.
	public func removeListener( _ listener: Listener ) {
		listeners.remove( listener as AnyObject )
	}
	
	/// Post offers event.
	/// - Parameters:
	///   - event: `Event` event.
	///   - emitter: `AnyObject?` object. Should be event emitter.
	///   - context: `AnyObject?` object. Any additional context.
	public func postOffersEvent( _ event: Event, from emitter: AnyObject?, with context: AnyObject? ) {
		notifyListenersWithEvent( event, from: emitter, with: context )
	}
	
	// Override and notify all listeners.
	public func notifyListenersWithEvent( _ event: Event, from emitter: AnyObject?, with context: AnyObject? ) {
	}
}
