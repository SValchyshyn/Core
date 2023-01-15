//
//  LanguagePluralCategoryConverter.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 20.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

/// Categories that is used for plural localization keys.
enum LanguagePluralCategory: String {
	case one, few, many, other
}

/// Converts value into `LanguagePluralCategory`.
/// Language Plural Rules - https://unicode-org.github.io/cldr-staging/charts/latest/supplemental/language_plural_rules.html
protocol LanguagePluralCategoryConverter {
	
	func category(for value: UInt) -> LanguagePluralCategory
	
}

/// Default implementation for languages that have only "one" and "other" categories, like English and Danish.
struct DefaultLanguagePluralCategoryConverter: LanguagePluralCategoryConverter {
	
	func category(for value: UInt) -> LanguagePluralCategory {
		value == 1 ? .one : .other
	}
	
}

struct RomaniaLanguagePluralCategoryConverter: LanguagePluralCategoryConverter {
	
	func category(for value: UInt) -> LanguagePluralCategory {
		if value == 1 {
			return .one
		} else if value == 0 || (2...19).contains(value % 100) {
			return .few
		}
		return .other
	}
	
}

struct UkrainianLanguagePluralCategoryConverter: LanguagePluralCategoryConverter {
	
	func category(for value: UInt) -> LanguagePluralCategory {
		if value % 10 == 1, value % 100 != 11 {
			return .one
		} else if (2...4).contains(value % 10), !(12...14).contains(value % 100) {
			return .few
		} else if value % 10 == 0 || (5...9).contains(value % 10) || (11...14).contains(value % 100) {
			return .many
		}
		return .other
	}
	
}
