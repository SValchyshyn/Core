// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
	platforms: [
		.iOS(.v13)
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Core",
            targets: ["Core",
					  "CoreDataManager",
					  "CoreNetworking",
					  "Log",
					  "RemoteLog",
					  "Tracking",
					  "UserDefault",
					  "CoopCore",
					  "CoreUserInterface",
					  "CoreNavigation",
					  "BaseAppConfiguration",
					  "DefaultAppConfiguration"]),
		.library(
			name: "Authentication",
			targets: ["Authentication",
					  "AuthenticationData",
					  "AuthenticationDomain"]),
		.library(
			name: "Stores",
			targets: ["Stores"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-collections.git", exact: "0.0.3"),
		.package(url: "https://github.com/apple/swift-log", exact: "1.4.4"),
		.package(url: "https://github.com/airbnb/lottie-ios.git", exact: "3.1.9"),
		.package(url: "https://github.com/ra1028/DifferenceKit.git", exact: "1.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "Stores",
			dependencies: [
				"AuthenticationDomain",
				"AuthenticationData",
				"CoopCore",
				"CoreUserInterface",
				"Log"
			],
			path: "Sources/Stores/Stores"),
		.target(
			name: "Authentication",
			dependencies: [
				"AuthenticationDomain",
				"AuthenticationData",
				"CoreUserInterface",
				"Core",
				"Log",
				"CoopCore",
				"DefaultAppConfiguration"
			],
			path: "Sources/Authentication/Authentication",
			resources: [
				.process("Resources")
			]),
		.target(
			name: "AuthenticationDomain",
			dependencies: [
				"Log",
				"CoopCore",
				"DefaultAppConfiguration"
			],
			path: "Sources/Authentication/AuthenticationDomain"),
		.target(
			name: "AuthenticationData",
			dependencies: [
				"DefaultAppConfiguration",
				"AuthenticationDomain",
				"CoreNetworking",
				"Log"
			],
			path: "Sources/Authentication/AuthenticationData"),
		.target(
			name: "BaseAppConfiguration",
			dependencies: [
				.product(name: "Logging", package: "swift-log"),
				"Core",
				"CoopCore",
				"UserDefault"
			],
			path: "Sources/AppConfiguration/BaseAppConfiguration"),
		.target(
			name: "DefaultAppConfiguration",
			dependencies: [
				.product(name: "Logging", package: "swift-log"),
				"CoopCore",
				"BaseAppConfiguration"
			],
			path: "Sources/AppConfiguration/DefaultAppConfiguration"),
		.target(
			name: "CoopCore",
			dependencies: [
				.product(name: "Logging", package: "swift-log"),
				"Core",
				"UserDefault",
				"Tracking"
			],
			path: "Sources/CoopCore"),
		.target(
			name: "CoreUserInterface",
			dependencies: [
				.product(name: "Logging", package: "swift-log"),
				.product(name: "Lottie", package: "lottie-ios"),
				.product(name: "DifferenceKit", package: "DifferenceKit"),
				"Core",
				"CoreNetworking",
				"CoreNavigation",
				"Tracking"
			],
			path: "Sources/CoreUI/CoreUserInterface"),
		.target(
			name: "CoreNavigation",
			dependencies: [
				.product(name: "Logging", package: "swift-log"),
				"Core"
			],
			path: "Sources/CoreUI/CoreNavigation"),
        .target(
            name: "Core",
			dependencies: [
				.product(name: "Collections", package: "swift-collections")
			],
			path: "Sources/Core"),
		.target(
			name: "CoreDataManager",
			dependencies: [
				"Core"
			],
			path: "Sources/CoreDataManager"),
		.target(
			name: "CoreNetworking",
			dependencies: [
				"RemoteLog",
			],
			path: "Sources/CoreNetworking"),
		.target(
			name: "Log",
			dependencies: [
				.product(name: "Logging", package: "swift-log"),
				"Core"
			],
			path: "Sources/Log"),
		.target(
			name: "RemoteLog",
			dependencies: [
				"Log",
				"CoreDataManager"
			],
			path: "Sources/RemoteLog"),
		.target(
			name: "Tracking",
			dependencies: [
				"Core"
			],
			path: "Sources/Tracking"),
		.target(
			name: "UserDefault",
			dependencies: [
				"Log"
			],
			path: "Sources/UserDefault"),
        .testTarget(
            name: "CoreTests",
            dependencies: [
				.byName(name: "CoreDataManager"),
				.byName(name: "CoreNetworking")
			],
			path: "Tests/CoreTests"),
		.testTarget(
			name: "LogTests",
			dependencies: [
				.byName(name: "Log")
			],
			path: "Tests/LogTests"),
		.testTarget(
			name: "UserDefaultTests",
			dependencies: [
				.byName(name: "UserDefault")
			],
			path: "Tests/UserDefaultTests"),
    ],
	swiftLanguageVersions: [.v5]
)
