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
        
        initializeTor()
    }
    
    func initializeTor() {
        switch TorManager.shared.state {
        case .none, .stopped:
            TorManager.shared.startTor(delegate: self)
        default:
            NSLog("Tor is already running")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }

}

extension InitializingTorViewController : TorManagerDelegate {
    func torConnectionProgress(_ progress: Int) {
        DispatchQueue.main.async {
            self.initializingLabel.text = NSLocalizedString("Bootstrapped", comment: "") + " \(progress)%"
        }
    }
    
    func torCircuitEstablished() {
        DispatchQueue.main.async {
            self.initializingLabel.text = NSLocalizedString("Tor connected", comment: "")
        }
    }
    
    func torSessionEstablished() {
        if Settings.isDojoEnabled {
            DojoManager.shared.connectToDojoWithStoredCredentials(delegate: self)
        } else {
            dismissView()
        }
    }
}

extension InitializingTorViewController : DojoManagerDelegate {
    func dojoConnProgress(_ progress: Int, localizedMessage: String) {
        DispatchQueue.main.async {
            self.initializingLabel.text = NSLocalizedString("Tor connected, connecting to Dojo", comment: "")
        }
    }
    
    func dojoConnFinished() {
        dismissView()
    }
    
    func dojoConnFailed(message: String) {
        DispatchQueue.main.async {
            self.initializingLabel.text = NSLocalizedString("Failed to connect to Dojo", comment: "")
        }
        dismissView()
    }
    
    
}
