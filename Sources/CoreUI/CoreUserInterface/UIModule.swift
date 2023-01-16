//
//  UIModule.swift
//  CoreUserInterface
//
//  Created by Stepan Valchyshyn on 03.08.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import Core

public final class UIModule {
	// MARK: - Singleton
	public static let shared = UIModule()
	private init() {}

	// MARK: - Injectables
	@Injectable fileprivate var commonStringsContent: CommonStringsProtocol
	@Injectable fileprivate var fontProvider: PlatformFontProvider
	@Injectable fileprivate var colorsProtocol: ColorsProtocol
	@Injectable fileprivate var animationsProtocol: AnimationsProtocol
}

let commonContent = UIModule.shared.commonStringsContent
let fontProvider = UIModule.shared.fontProvider
let colorsContent = UIModule.shared.colorsProtocol
let animationsContent = UIModule.shared.animationsProtocol
