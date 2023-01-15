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
            targets: ["Core", "CoreDataManager", "CoreNetworking", "Log", "RemoteLog", "Tracking", "UserDefault"]),
//		.library(
//			name: "CoreDataManager",
//			targets: ["CoreDataManager"]),
//		.library(
//			name: "CoreNetworking",
//			targets: ["CoreNetworking"]),
//		.library(
//			name: "Log",
//			targets: ["Log"]),
//		.library(
//			name: "Reachability",
//			targets: ["Reachability"]),
//		.library(
//			name: "RemoteLog",
//			targets: ["RemoteLog"]),
//		.library(
//			name: "Tracking",
//			targets: ["Tracking"]),
//		.library(
//			name: "UserDefault",
//			targets: ["UserDefault"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-collections.git", exact: "0.0.3"),
		.package(url: "https://github.com/apple/swift-log", exact: "1.4.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
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
    ]
)
