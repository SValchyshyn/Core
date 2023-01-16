//
//  Brand.swift
//  CoopModels
//
//  Created by Coruț Fabrizio on 16/12/2019.
//  Copyright © 2019 Greener Pastures. All rights reserved.
//

import Foundation
import UIKit

public extension CoopStore {
	/// Normalize store name regex.
	fileprivate static let normalizeStoreNameRegex = try? NSRegularExpression( pattern: "[^a-zæøå0-9]" )
	
	/// The `rawValue` is also used for annotationView reuse identifiers (since pins look alike for each brand).
	// swiftlint:disable:next type_body_length
	enum Brand: Codable, Hashable {
		public func encode( to encoder: Encoder ) throws {
			var container = encoder.singleValueContainer()
			try container.encode( rawValue )
		}
		
		public init( from decoder: Decoder ) throws {
			let rawStoreBrand = try decoder.singleValueContainer().decode( String.self )
			self = Brand( JSONString: rawStoreBrand ) ?? .unknown
		}
		
		case kvickly
		case brugsen
		case superBrugsen
		case dagliBrugsen
		case faktaGermany
		case irma
		case madCooperativet
		case coopMad
		case brugseni  // For Greenland only. NB: Used by both storefinder and paper offers (its "grønland" in store finder, "brugsenimedi" in paper offers).
		case catalogue( CatalogueType )
		case coop365
		case unknown
		
		// Canonical Brand raw values
		public var rawValue: String {
			// IMPORTANT: The raw values _must_ be lowercase and may _only_ contain a-å letters as the initializer will lowercase and remove non-a-å characters first.
			switch self {
			case .kvickly: return "kvickly"
			case .brugsen: return "brugsen"
			case .superBrugsen: return "superbrugsen"
			case .dagliBrugsen: return "daglibrugsen"
			case .faktaGermany: return "faktatyskland"
			case .irma: return "irma"
			case .madCooperativet: return "madcooperativet"
			case .coopMad: return "coopdkmad"
			case .brugseni: return "grønland" // For Greenland only. NB: Used by both storefinder and paper offers (its "grønland" in store finder, "brugsenimedi" in paper offers).
			case .catalogue( let catalogueType ): return catalogueType.rawValue
			case .coop365: return "coop365"
			case .unknown: return "---unknown---"
			}
		}

		/// The brand identifier in the whitelabel platform implementation
		public var platformID: String {
			switch self {
			case .brugsen: return Brand.brugsen.rawValue
			case .brugseni: return "17"
			case .catalogue( let catalogueType ): return catalogueType.rawValue
			case .coop365: return Brand.coop365.rawValue
			case .coopMad: return "1"
			case .dagliBrugsen: return "4"
			case .faktaGermany: return "11"
			case .irma: return "7"
			case .kvickly: return "2"
			case .madCooperativet: return Brand.madCooperativet.rawValue
			case .superBrugsen: return "3"
			case .unknown: return Brand.unknown.rawValue
			}
		}
		
		/// Initializer with different brand string variations found in API JSON
		public init?( JSONString: String ) {
			// Convert to lowercase and remove every character that is not a lowercase letter or a digit. Digits are needed for coop365.
			guard let regex = CoopStore.normalizeStoreNameRegex else { return nil }
			
			let simplifiedValue = regex.stringByReplacingMatches( in: JSONString.lowercased(), range: NSRange( location: 0, length: JSONString.count ), withTemplate: "" )
			
			self.init( rawValue: simplifiedValue )
		}
		
		/// Initializer for `Brand`. Since backend doesn't provide correct value for .coop365, we need to intercept store name and set coop365 brand manually.
		/// - Parameters:
		///   - JSONString: `String` object.
		///   - storeName: `String` object. Should be store name.
		public init?( JSONString: String, storeName: String ) {
			guard CoopStore.isCoop365Store( storeName: storeName ) else {
				self.init( JSONString: JSONString )
				return
			}
			
			// Set .coop365 if store name matches 365.
			self = .coop365
		}
		
		/// Required init in order to map multiple values to the same chain. The numeric values are the chain IDs from the white label platform.
		// swiftlint:disable:next cyclomatic_complexity
		public init?( rawValue: String ) {
			switch rawValue {
			case Brand.kvickly.rawValue, Brand.kvickly.platformID: 									self = .kvickly
			case Brand.brugsen.rawValue, Brand.brugsen.platformID: 									self = .brugsen
			case Brand.superBrugsen.rawValue, Brand.superBrugsen.platformID: 						self = .superBrugsen
			case Brand.dagliBrugsen.rawValue, Brand.dagliBrugsen.platformID:						self = .dagliBrugsen
			case Brand.faktaGermany.rawValue, Brand.faktaGermany.platformID, "faktagermany": 		self = .faktaGermany
			case Brand.irma.rawValue, Brand.irma.platformID: 										self = .irma
			case Brand.madCooperativet.rawValue, Brand.madCooperativet.platformID:					self = .madCooperativet
			case Brand.coopMad.rawValue, Brand.coopMad.platformID, "coopmad":						self = .coopMad
			case Brand.coop365.rawValue, Brand.coop365.platformID:                            		self = .coop365
			case Brand.brugseni.rawValue, Brand.brugseni.platformID: 								self = .brugseni
				
			// We parse coop shopping and samvirke as the same, since the coop shopping catalogue is returned as "samvirke".
			// However, the samvirke catalogue is also called "samvirke", but since this is presented in ShopGun, we don't show a title for it, so this is fine for now. -FSO
			case CatalogueType.shopping.rawValue, "samvirke", "coopdk": 	self = .catalogue( .shopping )
			case CatalogueType.books.rawValue: 								self = .catalogue( .books )
			case CatalogueType.kids.rawValue: 								self = .catalogue( .kids )
			case CatalogueType.garden.rawValue: 							self = .catalogue( .garden )
			case CatalogueType.gardenAndToys.rawValue: 						self = .catalogue( .gardenAndToys )
			case CatalogueType.toys.rawValue: 								self = .catalogue( .toys )
			case CatalogueType.house.rawValue: 								self = .catalogue( .house )
			case CatalogueType.fdbFurniture.rawValue: 						self = .catalogue( .fdbFurniture )
			case CatalogueType.furniture.rawValue: 							self = .catalogue( .furniture )
			case CatalogueType.beauty.rawValue: 							self = .catalogue( .beauty )
			case CatalogueType.christmas.rawValue: 							self = .catalogue( .christmas )
			case CatalogueType.spring.rawValue: 							self = .catalogue( .spring )
			case CatalogueType.bagsAndLuggage.rawValue:						self = .catalogue( .bagsAndLuggage )
			case CatalogueType.grill.rawValue:								self = .catalogue( .grill )
			case CatalogueType.cookingFolder.rawValue:						self = .catalogue( .cookingFolder )
			case CatalogueType.coop365.rawValue:                        	self = .catalogue( .coop365 )
				
			case Brand.unknown.rawValue:									self = .unknown
				
			default:
				if rawValue.contains("brugseni") {
					self = .brugseni
				}
				// TODO: In scope of Fakta RIP project there should be fallback to Coop365 in case backend sends Fakta chain id -ATK
				// TODO: It should be removed as soon as backend fully migrates to Coop365 -ATK
				else if rawValue.contains("fakta") || rawValue.contains("8") {
					self = .coop365
				} else {
					return nil
				}
			}
		}
		
		/// Brand image.
		public var image: UIImage? {
			switch self {
			case .kvickly: return #imageLiteral(resourceName: "gfx_offer_kvickly")
			case .brugsen: return #imageLiteral(resourceName: "gfx_offer_brugsen")
			case .superBrugsen: return #imageLiteral(resourceName: "gfx_offer_superbrugsen")
			case .dagliBrugsen: return #imageLiteral(resourceName: "gfx_offer_daglibrugsen")
			case .irma: return #imageLiteral(resourceName: "gfx_offer_irma")
			case .faktaGermany: return #imageLiteral(resourceName: "gfx_offer_fakta_germany")
			case .madCooperativet: return #imageLiteral(resourceName: "gfx_offer_madcoop")
			case .brugseni: return #imageLiteral(resourceName: "gfx_offer_brugseni")
			case .coopMad: return #imageLiteral(resourceName: "gfx_offer_coop_mad")
			case .catalogue( .grill ): return #imageLiteral(resourceName: "coop_box_color")
			case .catalogue: return #imageLiteral(resourceName: "gfx_offer_coop_shopping")
			case .coop365: return #imageLiteral(resourceName: "gfx_offer_coop365")
			case .unknown: return nil
			}
		}
		
		/// Large brand image.
		public var largeImage: UIImage? {
			switch self {
			case .kvickly: return #imageLiteral(resourceName: "gfx_offer_kvickly_large")
			case .brugsen: return #imageLiteral(resourceName: "gfx_offer_brugsen_large")
			case .superBrugsen: return #imageLiteral(resourceName: "gfx_offer_superbrugsen_large")
			case .dagliBrugsen: return #imageLiteral(resourceName: "gfx_offer_daglibrugsen_large")
			case .irma: return #imageLiteral(resourceName: "gfx_offer_irma_large")
			case .faktaGermany: return nil
			case .madCooperativet: return #imageLiteral(resourceName: "gfx_offer_madcoop_large")
			case .brugseni: return #imageLiteral(resourceName: "gfx_offer_brugseni_large")
			case .coopMad: return #imageLiteral(resourceName: "gfx_offer_coop_mad_large")
			case .catalogue: return #imageLiteral(resourceName: "logoCoopDkShoppingBlack")
			case .coop365: return #imageLiteral(resourceName: "gfx_offer_coop365_large")
			case .unknown: return nil
			}
		}
		
		public var filterImage: UIImage? {
			// We combine the filter graphic with the logo for this brand in order to get a custom filter image for the brand.
			return image.map { #imageLiteral(resourceName: "gfx_filter").mergeWith( topImage: $0 )}
		}
		
		/// Image for map annotation.
		public var pinImage: UIImage? {
			switch self {
			case .dagliBrugsen: return #imageLiteral(resourceName: "pin_daglibrugsen")
			case .irma: return #imageLiteral(resourceName: "pin_irma")
			case .kvickly: return #imageLiteral(resourceName: "pin_kvickly")
			case .superBrugsen: return #imageLiteral(resourceName: "pin_superbrugsen")
			case .brugseni: return #imageLiteral(resourceName: "pin_brugseni")
			case .coop365: return #imageLiteral(resourceName: "pin_coop365")
			case .faktaGermany, .brugsen, .madCooperativet, .coopMad, .unknown: return nil
			case .catalogue: return #imageLiteral(resourceName: "logoCoopDkShoppingBlack")
			}
		}

		/// Image for In-Store annotation.
		public var inStorePinImage: UIImage? {
			switch self {
			case .dagliBrugsen: return #imageLiteral(resourceName: "in_store_pin_daglibrugsen")
			case .irma: return #imageLiteral(resourceName: "in_store_pin_irma")
			case .kvickly: return #imageLiteral(resourceName: "in_store_pin_kvickly")
			case .superBrugsen: return #imageLiteral(resourceName: "in_store_pin_superbrugsen")
			case .coop365: return #imageLiteral(resourceName: "in_store_pin_coop365")
			case .catalogue, .brugseni, .faktaGermany, .brugsen, .madCooperativet, .coopMad, .unknown: return nil
			}
		}
		
		/// A white variation of the logo
		public var whiteImage: UIImage? {
			switch self {
			case .dagliBrugsen: return #imageLiteral(resourceName: "dagli_brugsen_white")
			case .irma: return #imageLiteral(resourceName: "irma_white")
			case .kvickly: return #imageLiteral(resourceName: "kvickly_white")
			case .superBrugsen: return #imageLiteral(resourceName: "super_brugsen_white")
			case .brugseni: return #imageLiteral(resourceName: "brugseni_white")
			case .coop365: return #imageLiteral(resourceName: "365_white")
			case .coopMad: return #imageLiteral(resourceName: "coop_mad_white")
			case .faktaGermany: return #imageLiteral(resourceName: "fakta_germany_white")
			case .catalogue: return #imageLiteral(resourceName: "coop_shopping_white")
			case .brugsen: return #imageLiteral(resourceName: "brugsen_white")
			case .madCooperativet, .unknown: return nil
			}
		}
		
		/// `true` if the printedOffers (tilbudsAviser) are handled by Shopgun SDK (eTilbudavis).
		public var isPublicationHandledByShopgun: Bool {
			switch self {
			case .dagliBrugsen, .superBrugsen, .irma, .kvickly, .faktaGermany, .brugseni, .coop365:
				return true
				
			case .brugsen, .madCooperativet, .coopMad, .unknown, .catalogue:
				return false
			}
		}
		
		/// TjekSDK dealer-id alias.
		public var shopgunDealerId: String? {
			switch self {
			case .kvickly: return "c1edq"
			case .superBrugsen: return "0b1e8"
			case .dagliBrugsen: return "d311fg"
			case .irma: return "d432U"
			case .faktaGermany: return "1e02AL"
			case .brugseni: return "4a10KU"
			case .coop365: return "DWZE1w"
			default: return nil
			}
		}
		
		/// Human readable store brand title.
		public var displayTitle: String {
			switch self {
			case .brugseni:
				// Found in Brugseni, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_greenlandic_chainname_medi", comment: "" )
				
			case .coopMad:
				// Found in CoopDK, but we cannot use it here until we extract the CoopStore out of CoopCore.
				// swiftlint:disable:next module_localization - Legacy. Will be cleaned up once we get rid of CoopStore from CoopCore.
				return NSLocalizedString( "offers_leaflet_food", comment: "" )
				
			case .catalogue( let catalogueType ):
				return catalogueType.name
				
			case .kvickly:
				return "Kvickly"
				
			case .superBrugsen:
				return "SuperBrugsen"
				
			case .dagliBrugsen:
				return "Dagli'Brugsen"
				
			case .irma:
				return "Irma"

			case .coop365:
				return "Coop 365discount"
				
			case  .brugsen, .faktaGermany, .madCooperativet, .unknown:
				return ""
			}
		}
		
		public static func excludeStoreNameFrom( _ combinedName: String ) -> String {
			// All variations of store names found in API
			let excludeNames = ["Brugsen", "Dagli'brugsen", "Daglibrugsen", "Irma", "Kvickly", "Lille Irma", "Lokalbrugsen", "Superbrugsen", "Mad Cooperativet", "Brugseni"]
			
			// Remove any occurrence of any brand name and finally trim whitespace
			return excludeNames.reduce( combinedName ) { cleanedName, brandName -> String in cleanedName.replacingOccurrences( of: brandName, with: "" ) }.trimmingCharacters( in: .whitespacesAndNewlines )
		}

		/// The brands to which a store can belong (for filter)
		public static let storeBrands: [Brand] = [.kvickly, .superBrugsen, .dagliBrugsen, .coop365, .irma]
		
		/// The brands to which an ascoiated store can belong (for filter)
		public static let ascoiatedStoreBrands: [Brand] = [.kvickly, .superBrugsen, .dagliBrugsen, .irma]
		
		// MARK: - Comparable
		
		public static func == ( lhs: CoopStore.Brand, rhs: CoopStore.Brand ) -> Bool {
			return lhs.rawValue == rhs.rawValue
		}
	}
	
	/// Returns bool flag is store is `Coop 365`
	/// - Parameter storeName: `String` object.
	/// - Returns: `Bool` flag. true if `coop 365`.
	static func isCoop365Store( storeName: String ) -> Bool {
		guard let regex = CoopStore.normalizeStoreNameRegex else { return false }
		
		let simplifiedValue = regex.stringByReplacingMatches( in: storeName.lowercased(), range: NSRange( location: 0, length: storeName.count ), withTemplate: "" )
		
		return simplifiedValue.hasPrefix( "coop365" ) || simplifiedValue.hasPrefix( "365discount" )
	}
}

private extension UIImage {
	/**
	Create a new image by overlaying the top image in the center of the currrent image.
	*/
	func mergeWith( topImage: UIImage ) -> UIImage {
		UIGraphicsBeginImageContextWithOptions( size, false, 0 ) // Setting the scale to 0 makes the function use the device scale
		
		// Draw the bottom image
		let areaSize = CGRect( x: 0, y: 0, width: size.width, height: size.height )
		self.draw( in: areaSize )
		
		// Draw the top image in the center
		let topImageSize = topImage.size
		let topImageRect = CGRect( origin: CGPoint(x: areaSize.width/2 - topImageSize.width/2, y: areaSize.height/2 - topImageSize.height/2), size: topImageSize )
		topImage.draw( in: topImageRect, blendMode: .normal, alpha: 1.0 )
		
		let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return mergedImage
	}
}
