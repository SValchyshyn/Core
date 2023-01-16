//
//  BackgroundImagesModule.swift
//  BackgroundImages
//
//  Created by Nazariy Vlizlo on 25.05.2020.
//  Copyright © 2020 Nazariy Vlizlo. All rights reserved.
//

import UIKit
import Log

// Wiki page describing BackgroundImagesModule is available here -https://dev.azure.com/loopbycoop/Samkaup/_wiki/wikis/Samkaup.wiki/130/iOS-BackgroundImagesModule

public protocol BackgroundImagesModule: AnyObject {
	var currentImageName: String? { get set }
	func newRandomBackgroundImageName() -> String
	func currentBackgroundImageFileName() -> String
	func currentBackgroundImage() -> UIImage
	func clearCurrentImageFileName()
	func loadImagesFrom(url: URL)
}

extension BackgroundImagesModule {
	/**
	Returns the name of the current background image. If no current image exists, a new one will be chosen.

	Due to OpenGL and caching issues, the _filename_ is returned and not the image object itself.
	*/
	public func currentBackgroundImageFileName() -> String {
		return currentImageName ?? newRandomBackgroundImageName()
	}

	/**
	Returns the current image. If no current image exists, a new, random image will be chosen.
	*/
	public func currentBackgroundImage() -> UIImage {
		guard let path = Bundle.main.path( forResource: self.currentBackgroundImageFileName(), ofType: nil ) else {
			Log.technical.log(.error, "Unable to load BackgroundImageController image from file", [.identifier("CoreUserInterface.fetchingCurrentBackgroundImage.1")])
			return UIImage()
		}
		return UIImage( contentsOfFile: path ) ?? UIImage()
	}

	/**
	Sets currentImageFileName to nil.
	*/
	public func clearCurrentImageFileName() {
		currentImageName = nil
	}

	public func loadImagesFrom(url: URL) {
		// MARK: TODO: Implement default functionality for downloading background images from cloud.
		// Right now we're getting them locally.
	}
}
