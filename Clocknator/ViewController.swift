//
//  ViewController.swift
//  Clocknator
//
//  Created by Paulo Mattos on 18/03/19.
//  Copyright © 2019 Paulo Mattos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var clock: ClocknatorView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func willEnterForeground() {
        clock.time = Date()
    }

    // MARK: - UI Tweaks
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
