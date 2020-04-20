//
//  NetworkViewController.swift
//  Sentinel
//
//  Created by Gigi on 20.04.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import UIKit
import Toast_Swift

class NetworkViewController: UIViewController {
    
    @IBOutlet weak var buttonTor: UIButton!
    @IBOutlet weak var buttonRenew: UIButton!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var viewStreetLight: UIView!
    @IBOutlet weak var buttonTorInfo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Network", comment: "")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        let close = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dissmiss))
        self.navigationItem.leftBarButtonItems = [close]
        
        #if DEBUG
        buttonTorInfo.isHidden = true
        #else
        buttonTorInfo.isHidden = true
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateViews()
    }
    
    @objc func dissmiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func torButtonPressed(_ sender: Any) {
        if TorManager.shared.state == .connected {
            TorManager.shared.stopTor()
            torDidStop()
        } else {
            TorManager.shared.startTor(delegate: self)
            torIsInitializing()
        }
    }
    
    @IBAction func renewPressed(_ sender: Any) {
        TorManager.shared.closeAllCircuits { (success) in
            // TODO - notify if NYM renew was successful
            
            TorManager.shared.torReconnect { (success) in
                if success {
                    NSLog("Tor reconnect successful. Tor identity renewed.")
                    self.showLocalizedToast("Tor identity renewed")
                } else {
                    NSLog("Tor reconnect failed")
                }
            }
        }
    }
    
    @IBAction func debugPressed(_ sender: Any) {
        TorManager.shared.showDebugInfo()
    }
    
    private func updateViews() {
        switch (TorManager.shared.state) {
        case .connected:
            torDidConnect()
        case .stopped, .none:
            torDidStop()
        case .started:
            torIsInitializing()
        }
    }
    
    private func showLocalizedToast(_ message: String) {
        DispatchQueue.main.async {
            self.view.makeToast(NSLocalizedString(message, comment: ""))
        }
    }
    
    private func torIsInitializing() {
        labelStatus.text = NSLocalizedString("Tor initializing...", comment: "")
        viewStreetLight.backgroundColor = UIColor.orange
        buttonRenew.isHidden = true
        buttonTor.setTitle(NSLocalizedString("LOADING...", comment: ""), for: .normal)
    }
    
    private func torDidConnect() {
        labelStatus.text = NSLocalizedString("Enabled", comment: "")
        viewStreetLight.backgroundColor = UIColor.green
        buttonRenew.isHidden = false
        buttonTor.setTitle(NSLocalizedString("DISABLE", comment: ""), for: .normal)
    }
    
    private func torDidStop() {
        labelStatus.text = NSLocalizedString("Disabled", comment: "")
        viewStreetLight.backgroundColor = UIColor.red
        buttonRenew.isHidden = true
        buttonTor.setTitle(NSLocalizedString("ENABLE", comment: ""), for: .normal)
    }
}

extension NetworkViewController : TorManagerDelegate {
    func torConnProgress(_ progress: Int) {
        DispatchQueue.main.async {
            self.labelStatus.text = NSLocalizedString("Bootstrapped", comment: "") + " \(progress)%"
        }
    }
    
    func torConnFinished() {
        DispatchQueue.main.async {
            self.torDidConnect()
        }
    }
}
