//
//  NetworkViewController.swift
//  Sentinel
//
//  Created by Gigi on 20.04.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import UIKit
import Toast_Swift
import QRCodeReader

class NetworkViewController: UIViewController {
    
    // Tor
    @IBOutlet weak var buttonTor: UIButton!
    @IBOutlet weak var buttonRenew: UIButton!
    @IBOutlet weak var buttonRenewWidth: NSLayoutConstraint!
    @IBOutlet weak var labelStatusTor: UILabel!
    @IBOutlet weak var viewStreetLightTor: UIView!
    
    // Dojo
    @IBOutlet weak var buttonDojo: UIButton!
    @IBOutlet weak var labelStatusDojo: UILabel!
    @IBOutlet weak var viewStreetLightDojo: UIView!
    
    // QR Scanner
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
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
        switch Sentinel.state {
        case .samouraiClear:
            TorManager.shared.startTor(delegate: self)
            updateViews()
        case .samouraiTor:
            TorManager.shared.stopTor()
            Settings.disableTor()
            updateViews()
        case .dojoTor:
            showTorDisableAlert(sender)
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
        buttonRenewWidth.constant = 0
        buttonTor.setTitle(NSLocalizedString("LOADING", comment: ""), for: .normal)
    }
    
    private func torDidConnect() {
        labelStatusTor.text = NSLocalizedString("Enabled", comment: "")
        viewStreetLightTor.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.8470588235, blue: 0.4117647059, alpha: 1)
        buttonRenew.isHidden = false
        buttonRenewWidth.constant = 55
        buttonTor.setTitle(NSLocalizedString("DISABLE", comment: ""), for: .normal)
    }
    
    private func torDidStop() {
        labelStatusTor.text = NSLocalizedString("Disabled", comment: "")
        viewStreetLightTor.backgroundColor = #colorLiteral(red: 0.6588235294, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
        buttonRenew.isHidden = true
        buttonRenewWidth.isActive = true
        buttonRenewWidth.constant = 0
        buttonTor.setTitle(NSLocalizedString("ENABLE", comment: ""), for: .normal)
    }
    
    private func showTorDisableAlert(_ sender: Any) {
        let alertTitle = NSLocalizedString("Disable Tor?", comment: "")
        let alertMessage = NSLocalizedString("You will be disconnected from your Dojo. You will have to scan/paste your pairing details again.", comment: "")
        let alertCancel = NSLocalizedString("Cancel", comment: "")
        let alertDisable = NSLocalizedString("Disable", comment: "")
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alertCancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: alertDisable, style: .destructive, handler: { action in
            DojoManager.shared.disableDojo()
            TorManager.shared.stopTor()
            Settings.disableDojo()
            Settings.disableTor()
            self.updateViews()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension NetworkViewController : TorManagerDelegate {
    func torConnectionProgress(_ progress: Int) {
        DispatchQueue.main.async {
            self.labelStatusTor.text = NSLocalizedString("Bootstrapped", comment: "") + " \(progress)%"
        }
    }
    
    func torCircuitEstablished() {
        DispatchQueue.main.async {
            self.labelStatusTor.text = NSLocalizedString("Connected", comment: "")
        }
    }
    
    func torSessionEstablished() {
        Settings.enableTor()
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
            showDojoActionSheet(sender)
        case .samouraiTor:
            showDojoActionSheet(sender)
        case .dojoTor:
            showDojoDisableAlert(sender)
        }
    }
    
    private func showDojoDisableAlert(_ sender: Any) {
        // According to the iOS HIG, "Yes" and "No" should be avoided in alerts
        // See: https://developer.apple.com/design/human-interface-guidelines/ios/views/alerts/
        let alertTitle = NSLocalizedString("Disable Dojo?", comment: "")
        let alertMessage = NSLocalizedString("You will have to scan/paste your pairing details again.", comment: "")
        let alertCancel = NSLocalizedString("Cancel", comment: "")
        let alertDisable = NSLocalizedString("Disable", comment: "")
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alertCancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: alertDisable, style: .destructive, handler: { action in
            DojoManager.shared.disableDojo()
            Settings.disableDojo()
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
            NSLog("Scan QR Code")
            self.readerVC.delegate = self
            self.readerVC.modalPresentationStyle = .formSheet
            self.present(self.readerVC, animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction) in
            NSLog("Dojo action sheet dismissed")
        }))

        self.present(alert, animated: true, completion: {})
    }
    
    private func setupDojoFromClipboard(delegate: DojoManagerDelegate) {
        let pasteboardString: String? = UIPasteboard.general.string
        guard let pairingString = pasteboardString else {
            delegate.dojoConnFailed(message: NSLocalizedString("Empty clipboard", comment: ""))
            return
        }
        NSLog("\(pairingString)")
        setupDojo(pairing: pairingString, delegate: delegate)
    }
    
    private func setupDojo(pairing: String, delegate: DojoManagerDelegate) {
        guard let dojoParams = DojoManager.shared.parsePairingDetails(jsonString: pairing, delegate: delegate) else {
            return
        }
        
        DojoManager.shared.state = .pairingValid
        
        switch Sentinel.state {
        case .samouraiClear:
            // Tor not running - start Tor
            TorManager.shared.startTor(delegate: self, { connected in
                DispatchQueue.main.async {
                    guard connected == true else {
                        return // Tor connection failure. Delegate is notified in startTor()
                    }
                    // Tor connected. Connect to Dojo
                    DojoManager.shared.connectToDojo(parameters: dojoParams, delegate: delegate)
                }
            })
            updateViews()
        default:
            // Tor already running - connect to Dojo
            DojoManager.shared.connectToDojo(parameters: dojoParams, delegate: delegate)
        }
    }
    
    private func dojoIsConnecting() {
        labelStatusDojo.text = NSLocalizedString("Connecting to Dojo...", comment: "")
        viewStreetLightDojo.backgroundColor = #colorLiteral(red: 0.7137254902, green: 0.6980392157, blue: 0.3764705882, alpha: 1)
        buttonDojo.setTitle(NSLocalizedString("CONNECTING", comment: ""), for: .normal)
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
        UserDefaults.standard.set(true, forKey: "isDojoEnabled")
        self.updateViews()
        self.showLocalizedToast("Successfully connected to Dojo")
    }
    
    func dojoConnFailed(message: String) {
        self.updateViews()
        self.showLocalizedToast(message)
    }
    
}

extension NetworkViewController: QRCodeReaderViewControllerDelegate {
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
        setupDojo(pairing: result.value, delegate: self)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}
