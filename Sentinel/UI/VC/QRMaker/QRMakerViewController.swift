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
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    init(wallet: Wallet, isReciving: Bool) {
        self.wallet = wallet
        self.isReciving = isReciving
        super.init(nibName: nil, bundle: nil)
        if isReciving {
            self.title = "Receiving Address"
        }else{
            self.title = "Account QR"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let info = data()
        
        let new = QRCode(info.0)
        qrImageView.image = new?.image
        
        addressLabel.text = info.1
        nameLabel.text = wallet.name
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
                let address = try! PublicKey(xpub: wallet.address, network: .main, index: UInt32(wallet.accIndex.value!)).derived(at: UInt32(wallet.accIndex.value!)).address
                return (address, address)
            case .bip49:
                let address = try! PublicKey(xpub: wallet.address, network: .main, index: UInt32(wallet.accIndex.value!)).derived(at: UInt32(wallet.accIndex.value!)).addressBIP49
                return (address, address)
            case .bip84:
                let address = try! PublicKey(xpub: wallet.address, network: .main, index: UInt32(wallet.accIndex.value!)).derived(at: UInt32(wallet.accIndex.value!)).addressBIP84
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
}
