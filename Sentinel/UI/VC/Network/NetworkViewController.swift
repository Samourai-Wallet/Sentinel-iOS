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
            UserDefaults.standard.set(false, forKey: "isTorEnabled")
        } else {
            TorManager.shared.startTor(delegate: self)
            torIsInitializing()
            UserDefaults.standard.set(true, forKey: "isTorEnabled")
        }
    }
    
    @IBAction func renewPressed(_ sender: Any) {
        TorManager.shared.closeAllCircuits { (success) in
            TorManager.shared.torReconnect { (success) in
                if success {
                    self.showLocalizedToast(NSLocalizedString("Tor identity renewed", comment: ""))
                } else {
                    self.showLocalizedToast(NSLocalizedString("Renew failed", comment: ""))
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
        viewStreetLight.backgroundColor = #colorLiteral(red: 0.7137254902, green: 0.6980392157, blue: 0.3764705882, alpha: 1)
        buttonRenew.isHidden = true
        buttonTor.setTitle(NSLocalizedString("LOADING...", comment: ""), for: .normal)
    }
    
    private func torDidConnect() {
        labelStatus.text = NSLocalizedString("Enabled", comment: "")
        viewStreetLight.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.8470588235, blue: 0.4117647059, alpha: 1)
        buttonRenew.isHidden = false
        buttonTor.setTitle(NSLocalizedString("DISABLE", comment: ""), for: .normal)
    }
    
    private func torDidStop() {
        labelStatus.text = NSLocalizedString("Disabled", comment: "")
        viewStreetLight.backgroundColor = #colorLiteral(red: 0.6588235294, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
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
