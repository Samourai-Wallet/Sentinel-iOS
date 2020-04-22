//
//  InitializingTorViewController.swift
//  Sentinel
//
//  Created by Gigi on 22.04.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import UIKit

class InitializingTorViewController: UIViewController {
    
    @IBOutlet weak var initializingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.startAnimating()
    }

}

extension InitializingTorViewController : TorManagerDelegate {
    func torConnProgress(_ progress: Int) {
        DispatchQueue.main.async {
            self.initializingLabel.text = NSLocalizedString("Bootstrapped", comment: "") + " \(progress)%"
        }
    }
    
    func torConnFinished() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
