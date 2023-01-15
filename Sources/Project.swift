//
//  Project.swift
//  Core
//
//  Created by Adrian Ilie on 26.01.2022.
//

// swiftlint:disable all
import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project.

let userDefault: Target = .framework(
	lobycoTarget: .UserDefault,
	dependencies: [
		.logPP,
		.Log
	]
)

let log: Target = .framework(
	lobycoTarget: .Log,
	dependencies: [
		.logPP,
		.Core
	]
)

let remoteLog: Target = .framework(
	lobycoTarget: .RemoteLog,
	dependencies: [
		.logPP,
		.targetFromProject(.Log),
		.Core,
		.CoreDataManager
	],
	coreDataModels: [ .init( "RemoteLog/Model/RemoteLogModel.xcdatamodeld" ) ]
)

let core: Target = .framework(
    lobycoTarget: .Core,
    resourceTypes: [ .strings ],
    dependencies: [
        .orderedCollectionsPP
    ],
    // Extra `Xcode Build Settings` customizations required.
    settings: .settings(
        configurations: [
            .enterpriseTest( settings: [:].testConstructs()
                            .enterpriseActiveCompilationCondition()
            ),
        ]
    )
)

let project: Project = .module(
	lobycoModule: .Core,
	packages: [
		.swiftLog,
		.aepCampaign,
		.aepCore,
		.aepAnalytics,
		.aepAssurance,
		.aepAudience,
		.aepPlaces,
		.aepUserProfile,
        .differenceKit,
		.datadog,
        .swiftCollections
	],
	targets: [
		.framework(
			lobycoTarget: .GoogleDependencies,
			dependencies: [
				.firebaseAnalyticsPP,
				.firebaseCrashlyticsPP,
				.firebasePerformancePP,
				.xcframework( path: "GoogleDependencies/GoogleMLKit/MLKitBarcodeScanning.xcframework" ),
				.xcframework( path: "GoogleDependencies/GoogleMLKit/MLKitCommon.xcframework" ),
				.xcframework( path: "GoogleDependencies/GoogleMLKit/MLKitVision.xcframework" ),
				.xcframework( path: "GoogleDependencies/GoogleMLKit/MLImage.xcframework" ),
				.xcframework( path: "GoogleDependencies/GoogleMLKit/GoogleToolboxForMac.xcframework" ),
				.xcframework( path: "GoogleDependencies/GoogleMLKit/GoogleUtilitiesComponents.xcframework" ),
				.xcframework( path: "GoogleDependencies/GoogleMLKit/Protobuf.xcframework" ),
				.promisesPP,
				.nanopbPP,
				.googleDataTransportPP,
				.gtmSessionFetcherPP
			],
			settings: .googleSettings
		),
		log,
		log.testTarget(dependencies: [
			.logPP,
			.targetFromProject(.Log),
			.targetFromProject(.Core)
		]),
		.framework(
			lobycoTarget: .Reachability,
			headers: .headers(
				public: .init(
					[
						"Reachability/Reachability.h",
						"Reachability/AppleReachability.h"
					]
				)
			),
			dependencies: [
				.logPP,
				.targetFromProject(.Log),
				.targetFromProject(.RemoteLog)
			]
		),
		remoteLog,
		remoteLog.testTarget(dependencies: [
			.logPP,
			.targetFromProject(.Log),
			.targetFromProject(.RemoteLog)
		]),
		.framework(
			lobycoTarget: .CoreDataManager,
            dependencies: [
				.logPP,
				.targetFromProject(.Log),
                .targetFromProject(.Core)
            ]
		),
        .framework(
            lobycoTarget: .Tracking,
            dependencies: [
				.logPP,
				.targetFromProject(.Log),
                .Core,
                .CoreNavigation
            ]
        ),
        core,
        core.testTarget(
            dependencies: [
                .targetFromProject( .Core )
            ],
            coreDataModelsPaths: [ "CDTM.xcdatamodeld" ]
        ),
		.framework(
			lobycoTarget: .TrackingAdobe,
			dependencies: [
				.logPP,
				.targetFromProject(.Log),
				.CoopCore,
				.CoopUI,
				.Reachability,
				.UserDefault,
				.sdk( name: "AdSupport", type: .framework ),
				.aepAssurance,
				.aepCore,
				.aepLifecycle,
				.aepIdentity,
				.aepSignal,
				.aepAnalytics,
				.aepCampaign,
				.aepPlaces,
				.aepAudience,
				.aepUserProfile,
				.CoopFeatureManager,
				.CoopPushNotifications,
				.targetFromProject(.Tracking)
			]
		),
		.framework(
			lobycoTarget: .TrackingFirebase,
			dependencies: [
				.logPP,
				.targetFromProject(.Log),
				.targetFromProject(.Tracking),
				.targetFromProject(.GoogleDependencies)
			]
		),
        .framework(
            lobycoTarget: .CoreNetworking,
            dependencies: [
				.logPP,
				.targetFromProject(.Log),
				.datadogPP,
                .Core,
                .Reachability,
				.PlatformDatadog
            ]
        ),
        .framework(
            lobycoTarget: .UnleashFeatureManager,
            dependencies: [
				.logPP,
				.targetFromProject(.Log),
                .Core,
                .UserDefault
            ]
        ),
		userDefault,
		userDefault.testTarget(),
	]
)

/// 1:1 mapping between `Lobyco.Module.Target` enum cases and local enum.
/// We perform this extra mapping just so that we cannot use the `.targetFromProject(_:)` method
/// with a `Lobyco.Module.Target` from _another project_.
fileprivate enum ProjectTarget: String {
	case Log, Reachability, GoogleDependencies, RemoteLog, Tracking, TrackingAdobe, TrackingFirebase, UserDefault, Core, CoreDataManager, CoreNetworking, UnleashFeatureManager
}

fileprivate extension TargetDependency {

	/// Type-safe way to reference `TargetDependencies` from within the same `Project`.
	static func targetFromProject( _ projectTarget: ProjectTarget ) -> TargetDependency {
		.target( name: projectTarget.rawValue )
	}
}

// swiftlint:enable all
