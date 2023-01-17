//
//  AuthenticationModule.swift
//  Authentication
//
//  Created by Stepan Valchyshyn on 05.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Core
import CoreUserInterface

public final class AuthenticationModule {
	// MARK: - Singleton
	public static let shared = AuthenticationModule()
	private init() {}

	// MARK: - Injectables
	@Injectable fileprivate var fontProvider: PlatformFontProvider
	@Injectable fileprivate var colorsProtocol: ColorsProtocol
}

let fontProvider = AuthenticationModule.shared.fontProvider
let colorsContent = AuthenticationModule.shared.colorsProtocol
