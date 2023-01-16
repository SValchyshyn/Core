//
//  ColorsProtocol.swift
//  CoreUserInterface
//
//  Created by Nazariy Vlizlo on 27.07.2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit

public protocol ColorsProtocol {

	// MARK: UIColors
	var primaryColor: UIColor { get }
	var onPrimaryColor: UIColor { get }
	var secondaryColor: UIColor { get }
	var onSecondaryColor: UIColor { get }
	var priceTagColor: UIColor { get }
	var colorBackground: UIColor { get }
	var colorSurface: UIColor { get }
	var overlayDark: UIColor { get }
	var overlayLight: UIColor { get }
	var infoColor: UIColor { get }
	var successColor: UIColor { get }
	var criticalColor: UIColor { get }
	var dividerColor: UIColor { get }
	var dividerStrongColor: UIColor { get }
	var inactiveColor: UIColor { get }
	var hoverColor: UIColor { get }
	var colorCore: UIColor { get }
	var coreInvertedColor: UIColor { get }
	
	// MARK: Interactive colors
	var interactivePrimary: UIColor { get }
	var onPrimaryInteractiveColor: UIColor { get }
	var secondaryInteractiveColor: UIColor { get }
	var onSecondaryInteractiveColor: UIColor { get }
	var inactiveInteractiveColor: UIColor { get }
	var onInactiveInteractiveColor: UIColor { get }
	
	// MARK: Illustration Colors
	var primaryIllustrationDark: UIColor { get }
	var illustrationPrimary: UIColor { get }
	var illustrationPrimaryLight: UIColor { get }
	var primaryIllustrationLightest: UIColor { get }
	var secondaryIllustration: UIColor { get }
	var secondaryIllustrationLight: UIColor { get }
	var secondaryIllustrationLightest: UIColor { get }
	var illustrationDaark: UIColor { get }
	var illustrationMedium: UIColor { get }
	var illustrationLight: UIColor { get }
	
	// MARK: Text colors
	var bodyTextColor: UIColor { get } /// former colorTextCore   
	var colorTextReduced: UIColor { get }
	var coreInverted: UIColor { get }
	var textReducedInverted: UIColor { get }
	var labelTextColor: UIColor { get }
	var textLink: UIColor { get }
	var textLinkInverted: UIColor { get }
	var header1TextColor: UIColor { get }
	var header2TextColor: UIColor { get }
	var header3TextColor: UIColor { get }
	var header3LightTextColor: UIColor { get }
	var header4TextColor: UIColor { get }
	var header5TextColor: UIColor { get }
	var header6TextColor: UIColor { get }
	
	// check and clean
	var overlayColor: UIColor { get }
	var contextSnackbarColor: UIColor { get }
	var warningColor: UIColor { get }
}
