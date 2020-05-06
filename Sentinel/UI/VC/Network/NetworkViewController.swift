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
    
    // Tor
    @IBOutlet weak var buttonTor: UIButton!
    @IBOutlet weak var buttonRenew: UIButton!
    @IBOutlet weak var labelStatusTor: UILabel!
    @IBOutlet weak var viewStreetLightTor: UIView!
    
    // Dojo
    @IBOutlet weak var buttonDojo: UIButton!
    @IBOutlet weak var labelStatusDojo: UILabel!
    @IBOutlet weak var viewStreetLightDojo: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Network", comment: "")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        let close = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismissView))
        self.navigationItem.leftBarButtonItems = [close]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateViews()
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateViews() {
        // Tor
        switch (TorManager.shared.state) {
        case .connected:
            torDidConnect()
        case .stopped, .none:
            torDidStop()
        case .started:
            torIsInitializing()
        }
        
        // Dojo
        switch (DojoManager.shared.state) {
        case .paired:
            dojoDidConnect()
        case .none, .pairingValid:
            dojoDidStop()
        case .authenticating:
            dojoIsConnecting()
        }
    }
    
    private func showLocalizedToast(_ message: String) {
        DispatchQueue.main.async {
            self.view.makeToast(NSLocalizedString(message, comment: ""))
        }
    }
    
}

// MARK: Tor

extension NetworkViewController {
    
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
    
    private func torIsInitializing() {
        labelStatusTor.text = NSLocalizedString("Tor initializing...", comment: "")
        viewStreetLightTor.backgroundColor = #colorLiteral(red: 0.7137254902, green: 0.6980392157, blue: 0.3764705882, alpha: 1)
        buttonRenew.isHidden = true
        buttonTor.setTitle(NSLocalizedString("LOADING...", comment: ""), for: .normal)
    }
    
    private func torDidConnect() {
        labelStatusTor.text = NSLocalizedString("Enabled", comment: "")
        viewStreetLightTor.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.8470588235, blue: 0.4117647059, alpha: 1)
        buttonRenew.isHidden = false
        buttonTor.setTitle(NSLocalizedString("DISABLE", comment: ""), for: .normal)
    }
    
    private func torDidStop() {
        labelStatusTor.text = NSLocalizedString("Disabled", comment: "")
        viewStreetLightTor.backgroundColor = #colorLiteral(red: 0.6588235294, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
        buttonRenew.isHidden = true
        buttonTor.setTitle(NSLocalizedString("ENABLE", comment: ""), for: .normal)
    }
    
}

extension NetworkViewController : TorManagerDelegate {
    func torConnProgress(_ progress: Int) {
        DispatchQueue.main.async {
            self.labelStatusTor.text = NSLocalizedString("Bootstrapped", comment: "") + " \(progress)%"
        }
    }
    
    func torConnFinished() {
        DispatchQueue.main.async {
            self.torDidConnect()
        }
    }
}

// MARK: Dojo

extension NetworkViewController {
    
    @IBAction func dojoButtonPressed(_ sender: Any) {
        switch Sentinel.state {
        case .samouraiClear:
            showLocalizedToast("Tor must be enabled for Dojo pairing")
        case .samouraiTor:
            showDojoActionSheet(sender)
        case .dojoTor:
            showDojoDisableAlert(sender)
        }
    }
    
    private func showDojoDisableAlert(_ sender: Any) {
        // According to the iOS HIG, "Yes" and "No" should be avoided in alerts
        // See: https://developer.apple.com/design/human-interface-guidelines/ios/views/alerts/
        
        // TODO: i18n
        let alert = UIAlertController(title: "Disable Dojo?", message: "You will have to scan/paste your pairing details again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Disable", style: .destructive, handler: { action in
            DojoManager.shared.disableDojo()
            self.updateViews()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showDojoActionSheet(_ sender: Any) {
        let dojoTitle = NSLocalizedString("Power Sentinel with your own personal DOJO full node", comment: "")
        let dojoMessage = NSLocalizedString("Powering Samourai Wallet with your own personal node offers the best level of privacy and independence when interacting with the bitcoin network. Dojo makes running a full node easy and simple.", comment: "")
        
        let alert = UIAlertController(title: dojoTitle, message: dojoMessage, preferredStyle: .actionSheet)

        let pasteDetails = NSLocalizedString("Paste Details", comment: "")
        alert.addAction(UIAlertAction(title: pasteDetails, style: .default , handler:{ (UIAlertAction) in
            NSLog("Paste Details")
            self.setupDojoFromClipboard(delegate: self)
        }))

        let scanQRCode = NSLocalizedString("Scan QR Code", comment: "")
        alert.addAction(UIAlertAction(title: scanQRCode, style: .default , handler:{ (UIAlertAction) in
            // TODO
            NSLog("Scan QR Code")
        }))

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction) in
            NSLog("Dojo action sheet dismissed")
        }))

        self.present(alert, animated: true, completion: {})
    }
    
    private func setupDojoFromClipboard(delegate: DojoManagerDelegate) {
        let pasteboardString: String? = UIPasteboard.general.string
        guard let pairingString = pasteboardString else {
            NSLog("Empty clipboard") // TODO
            return
        }
        NSLog("\(pairingString)")
        setupDojo(pairing: pairingString, delegate: delegate)
    }
    
    private func setupDojo(pairing: String, delegate: DojoManagerDelegate) {
        guard let dojoParams = DojoManager.shared.getPairingDetails(jsonString: pairing, delegate: delegate) else {
            NSLog("Failed to parse pairing details") // TODO
            return
        }
        
        DojoManager.shared.state = .pairingValid
        DojoManager.shared.pairWithDojo(parameters: dojoParams, delegate: delegate)
        // TODO
    }
    
    private func dojoIsConnecting() {
        labelStatusDojo.text = NSLocalizedString("Connecting to Dojo...", comment: "")
        viewStreetLightDojo.backgroundColor = #colorLiteral(red: 0.7137254902, green: 0.6980392157, blue: 0.3764705882, alpha: 1)
        buttonDojo.setTitle(NSLocalizedString("CONNECTING...", comment: ""), for: .normal)
    }
    
    private func dojoDidConnect() {
        labelStatusDojo.text = NSLocalizedString("Enabled", comment: "")
        viewStreetLightDojo.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.8470588235, blue: 0.4117647059, alpha: 1)
        buttonDojo.setTitle(NSLocalizedString("DISABLE", comment: ""), for: .normal)
    }
    
    private func dojoDidStop() {
        labelStatusDojo.text = NSLocalizedString("Disabled", comment: "")
        viewStreetLightDojo.backgroundColor = #colorLiteral(red: 0.6588235294, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
        buttonDojo.setTitle(NSLocalizedString("ENABLE", comment: ""), for: .normal)
    }
    
}

extension NetworkViewController : DojoManagerDelegate {
    
    func dojoConnProgress(_ progress: Int, localizedMessage: String) {
        self.updateViews()
        self.labelStatusDojo.text = localizedMessage
    }
    
    func dojoConnFinished() {
        self.updateViews()
        self.showLocalizedToast("Successfully connected to Dojo")
    }
    
    func dojoConnFailed(message: String) {
        self.updateViews()
        self.showLocalizedToast(message)
    }
    
}
