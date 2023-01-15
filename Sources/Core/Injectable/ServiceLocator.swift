//
//  ServiceLocator.swift
//  CoopCore
//
//  Created by Stepan Valchyshyn on 26.05.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Foundation

// Wiki page describing ServiceLocator is available here - https://dev.azure.com/loopbycoop/Samkaup/_wiki/wikis/Samkaup.wiki/179/Dependency-Injection

/// A factory closure that is stored to return a Service type once requested.
public typealias ServiceFactoryClosure<Service> = () -> Service

/// A protocol to for a module to register dependencies that it provides.
public protocol ServiceLocatorModule {
	/// Register all of module services in this function. Trigger in the AppDelegate.
	func registerServices(_ serviceLocator: ServiceLocator )
}

/// A singleton `Service Locator` pattern implementation. Register your dependencies with a factory closure or a singleton.
public final class ServiceLocator {
	/// A dictionary to store type identifier with a coresponding factory closure or singleton instance.
	private var _registry = [ObjectIdentifier: Any]()
	
	// MARK: - Singleton
	
	public static let sharedLocator = ServiceLocator()
	init() {}

	// MARK: - Service Registration
	
	/**
	Register a service.

	- parameter factory:	A factory-like closure to build a dependency each time requested.
	*/
	public func register<Service>(_ factory: @escaping ServiceFactoryClosure<Service> ) {
		// Get a type identifier.
		let serviceId = ObjectIdentifier( Service.self )
		
		// Register type factory closure with type identifier as a key.
		self._registry[serviceId] = factory
	}

	public static func register<Service>(_ factory: @escaping ServiceFactoryClosure<Service> ) {
		self.sharedLocator.register( factory )
	}
	
	// MARK: - Singleton Service Registration
	
	/**
	Register a service.

	- parameter singletonInstance:	Type instance. Usually a singleton.
	*/
	public func registerSingleton<Service>(_ singletonInstance: Service ) {
		// Get a type identifier.
		let serviceId = ObjectIdentifier( Service.self )
		
		// Register type instance with type identifier as a key.
		self._registry[serviceId] = singletonInstance
	}

	public static func registerSingleton<Service>(_ singletonInstance: Service ) {
		self.sharedLocator.registerSingleton( singletonInstance )
	}
	
	// MARK: - Module Services Registration

	/**
	Register modules services. Call in AppDelegate.

	- parameter modules:	An array of app modules that should register their provided services.
	*/
	public func registerModules(_ modules: [ServiceLocatorModule] ) {
		modules.forEach { $0.registerServices( self ) }
	}

	public static func registerModules( modules: [ServiceLocatorModule] ) {
		self.sharedLocator.registerModules( modules )
	}
	
	// MARK: - Service Injection
	
	/// Inject a dependency. Fails with a fatalError if dependency is not yet in the registry.
	public static func inject<Service>() -> Service {
		return self.sharedLocator.inject()
	}
	
	/// Inject a dependency. Returns nil if dependency is not yet in the registry.
	public static func injectSafe<Service>() -> Service? {
		return self.sharedLocator.injectSafe()
	}
}

// MARK: - Private

private extension ServiceLocator {
	/// This method is private because no service which wants to request other services should
	/// bind itself to specific instance of a service locator.
	///
	/// - Returns: the injected service
	func inject<Service>() -> Service {
		let service: Service? = getServiceIfPresent()
		
		if let service = service {
			return service
		} else {
			// Such a dependency was not registered
			// Log an error
			NSLog("No registered entry for \( Service.self )")
			fatalError( "ServiceLocator: no registered entry for \( Service.self )" )
		}
	}
	
	/// This method is private because no service which wants to request other services should
	/// bind itself to specific instance of a service locator.
	///
	/// - Returns: the injected service
	func injectSafe<Service>() -> Service? {
		return getServiceIfPresent()
	}
	
	/// Search for appropriate Service. Return nil if not found
	func getServiceIfPresent<Service>() -> Service? {
		// Get a unique identifier for the Service type
		let serviceId = ObjectIdentifier( Service.self )
		if let factoryClosure = _registry[serviceId] as? ServiceFactoryClosure<Service> {
			// Search for a factory closure for this type
			// Construct a dependency
			return factoryClosure()
		} else if let singletonInstance = _registry[serviceId] as? Service {
			// Search for a registered singleton instance for this type
			return singletonInstance
		} else {
			// Such a dependency was not registered
			return nil
		}
	}
}
