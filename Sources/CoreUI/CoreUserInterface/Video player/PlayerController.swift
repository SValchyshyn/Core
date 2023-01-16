//
//  PlayerController.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 23.12.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit
import AVKit

public protocol PlayerControllerDelegate: AnyObject {
	/// Method for showing choosed playerViewController
	func show(playerViewController: UIViewController, completion: (() -> Void)?)
}

// Default implementation for view controllers
public extension PlayerControllerDelegate where Self: UIViewController {
	func show( playerViewController: UIViewController, completion: (() -> Void)?) {
		presentInFullScreen(playerViewController, animated: true, completion: completion)
	}
}

// Protocol implemented by objects which can handle a video URL
public protocol VideoPlaying: AnyObject {
	func playVideo( videoURL: URL )
}

// Objects conforming to `PlayerControllerDelegate` get a default implementation of the protocol.
public extension VideoPlaying where Self: PlayerControllerDelegate {
	func playVideo( videoURL: URL ) {
		let playerController = PlayerController(delegate: self, showCloseButton: true)
		playerController.playVideoUrl(videoURL)
	}
}

public class PlayerController {
	
	private weak var delegate: PlayerControllerDelegate?
	private var showCloseButton: Bool

	// MARK: Initialization
	public init(delegate: PlayerControllerDelegate, showCloseButton: Bool = false) {
		self.delegate = delegate
		self.showCloseButton = showCloseButton
	}
	
	// MARK: Public methods
	/// Play a video from url
	public func playVideoUrl(_ videoUrl: URL?) {
		guard let videoUrl = videoUrl else {
			return
		}
		let videoType = VideoType(urlString: videoUrl.absoluteString)
		
		switch videoType {
		case .mp4:
			showVideoPlayer(withURL: videoUrl)
			
		case .html:
			showWebPlayer(withURL: videoUrl)
		}
	}
}

// MARK: Private methods
private extension PlayerController {
	/// Show native iOS video player
	func showVideoPlayer(withURL url: URL) {
		let player = AVPlayer(url: url)
		let playerViewController = AVPlayerViewController()
		playerViewController.player = player
		
		if player.currentItem?.asset.isPlayable == true {
			delegate?.show(playerViewController: playerViewController) {
				playerViewController.player?.play()
			}
		} else {
			showWebPlayer(withURL: url)
		}
	}
	
	/// Show web video player
	func showWebPlayer(withURL url: URL) {
		let webPlayerViewController = WebPlayerViewController(url: url, showCloseButton: showCloseButton)
		delegate?.show(playerViewController: webPlayerViewController, completion: nil)
	}
}
