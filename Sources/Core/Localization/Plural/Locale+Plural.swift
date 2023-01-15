//
//  Locale+Plural.swift
//  CoopCore
//
//  Created by Olexandr Belozierov on 20.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation

extension Locale {
	
	/// Returns language plural category for value based on locale.
	func languagePluralCategory(for value: Int) -> LanguagePluralCategory {
		languagePluralCategoryConverter.category(for: value.magnitude)
	}
	
	private var languagePluralCategoryConverter: LanguagePluralCategoryConverter {
		switch languageCode {
		case "ro": return RomaniaLanguagePluralCategoryConverter()
		case "uk": return UkrainianLanguagePluralCategoryConverter()
		default: return DefaultLanguagePluralCategoryConverter()
		}
	}
	
}
