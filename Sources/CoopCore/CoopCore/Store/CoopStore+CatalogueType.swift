//
//  CatalogueType.swift
//  CoopModels
//
//  Created by Coruț Fabrizio on 16/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation

public extension CoopStore {
	enum CatalogueType: String, Codable, CaseIterable {
		case shopping = "coopshopping"
		case kids = "coopdkboern"
		case fdbFurniture = "coopdkfdbmoebler"
		case furniture = "coopdkshoppingmoebler"
		case books = "coopdkbogtilbud"
		case garden = "coopdkhaveliv"
		case gardenAndToys = "coopdkshoppinghavelivoglegetoej"
		case toys = "coopdkshoppinglegetoejskatalog"
		case house = "coopdkshoppingboligoggalleri"
		case beauty = "coopdkshoppingtilbudpaaskoenhed"
		case spring = "coopdkshoppingforaar"
		case christmas = "coopdkshoppingjul"
		case grill = "grillmagasin"
		case bagsAndLuggage = "coopdkshoppingtaskerogkufferter"
		case cookingFolder = "coopdkshoppingkoekkenfolder"
		case coop365 = "coop365catalogue"

		/// Human readable name of the catalogue.
		var name: String {
			switch self {
			case .shopping:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping", comment: "" )

			case .kids:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_kids", comment: "" )

			case .fdbFurniture:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_furniture", comment: "" )

			case .furniture:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_moebler", comment: "" )
				
			case .books:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_book", comment: "" )

			case .garden:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_haveliv", comment: "" )

			case .gardenAndToys:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_haveliv2", comment: "" )

			case .toys:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_catalog", comment: "" )

			case .house:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_bolig", comment: "" )

			case .beauty:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_skonhed", comment: "" )

			case .spring:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_foraar", comment: "" )

			case .christmas:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_jul", comment: "" )

			case .bagsAndLuggage:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_bags", comment: "" )

			case .grill:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_grill_catalogue", comment: "" )

			case .cookingFolder:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_shopping_koekkenfolder", comment: "" )
				
			case .coop365:
				// Coop365 catalogue does not have a title on Android, should be treated when CoopStore is moved out of CoopCore.
				return "Coop 365 discount"
			}
		}
	}
}
