//
//  AppConfigViewController.swift
//  BaseAppConfiguration
//
//  Created by Olexandr Belozierov on 04.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import UIKit
import Combine

class AppConfigViewController: UIViewController {
	
	@IBOutlet private var baseURLControl: UISegmentedControl!
	@IBOutlet private var appConfigVersionLabel: UILabel!
	
	private let viewModel: AppConfigViewModel
	private var subscriptions = [AnyCancellable]()
	
	init(viewModel: AppConfigViewModel) {
		self.viewModel = viewModel
		super.init(nibName: String(describing: Self.self), bundle: .module)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		bindViews()
		configureBaseURLControl()
	}
	
	// MARK: Binding
	
	private func bindViews() {
		viewModel.appConfigVersionPublisher
			.sink { [unowned self] version in appConfigVersionLabel.text = version }
			.store(in: &subscriptions)
		
		viewModel.errorPublisher
			.sink { error in print(error) }
			.store(in: &subscriptions)
	}
	
	// MARK: Base URL
	
	private func configureBaseURLControl() {
		baseURLControl.removeAllSegments()
		for (index, title) in viewModel.baseURLConfigurationTitles.enumerated() {
			baseURLControl.insertSegment(withTitle: title, at: index, animated: false)
		}
		
		baseURLControl.selectedSegmentIndex = viewModel.selectedBaseURLConfigurationIndex ?? -1
		baseURLControl.addTarget(self, action: #selector(baseURLControlChanged), for: .valueChanged)
	}
	
	// MARK: Actions
	
	@IBAction private func resetAppConfig() {
		viewModel.resetAppConfig()
	}
	
	@IBAction func clearAllData(_ sender: Any) {
		viewModel.clearAllData()
	}
	
	@objc private func baseURLControlChanged(_ sender: UISegmentedControl) {
		viewModel.selectedBaseURLConfigurationIndex = sender.selectedSegmentIndex
	}
	
	@IBAction private func close() {
		dismiss(animated: true)
	}
	
}
