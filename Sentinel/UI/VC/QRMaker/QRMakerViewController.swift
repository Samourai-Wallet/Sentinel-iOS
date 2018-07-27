//
//  QRMakerViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 04.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import HDWalletKit

class QRMakerViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let wallet: Wallet
    let isReciving: Bool
    @IBOutlet var qrImageView: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    init(wallet: Wallet, isReciving: Bool) {
        self.wallet = wallet
        self.isReciving = isReciving
        super.init(nibName: nil, bundle: nil)
        if isReciving {
            self.title = "Receiving Address"
        }else{
            self.title = wallet.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let info = data()
        
        let new = QRCode(info.0)
        qrImageView.image = new?.image
        
        addressLabel.text = info.1
        
        if let type = wallet.address.addrType() {
            switch type {
            case .bech32, .bip84:
                typeLabel.text = "Segwit"
            case .p2sh, .bip49:
                typeLabel.text = "Segwit Compatibility"
            case .p2pkh, .pub:
                typeLabel.text = "Standard"
            }
        }
        
        let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction))
        self.navigationItem.rightBarButtonItems = [shareItem]
    }
    
    @objc func shareAction() {
        let activityViewController = UIActivityViewController(activityItems: [shareImage()], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func shareImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: view.bounds.width, height: view.bounds.width + addressLabel.bounds.height + 8), false, UIScreen.main.scale)
        
        view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    private func data() -> (String, String) {
        guard let addrType = wallet.address.addrType() else {
            return ("", "")
        }
        
        if isReciving {
            switch addrType {
            case .bech32:
                return (wallet.address.uppercased(), wallet.address.lowercased())
            case .p2pkh, .p2sh:
                return (wallet.address, wallet.address)
            case .pub:
                let index = (wallet.accIndex.value != nil) ? wallet.accIndex.value! : 0
                let address = try! PublicKey(xpub: wallet.address, network: .main).derived(index: UInt32(index)).address
                return (address, address)
            case .bip49:
                let index = (wallet.accIndex.value != nil) ? wallet.accIndex.value! : 0
                let address = try! PublicKey(xpub: wallet.address, network: .main).derived(index: UInt32(index)).addressBIP49
                return (address, address)
            case .bip84:
                let index = (wallet.accIndex.value != nil) ? wallet.accIndex.value! : 0
                let address = try! PublicKey(xpub: wallet.address, network: .main).derived(index: UInt32(index)).addressBIP84
                return (address.uppercased(), address.lowercased())
            }
        } else {
            if addrType == .bech32 {
                return (wallet.address.uppercased(), wallet.address.lowercased())
            }else {
                return (wallet.address, wallet.address)
            }
        }
    }
    
    @IBAction func saveToClipboard(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Copied", message: "Public key has been copied to your clipboard!", preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            UIPasteboard.general.string = self.addressLabel.text
        }
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
}
