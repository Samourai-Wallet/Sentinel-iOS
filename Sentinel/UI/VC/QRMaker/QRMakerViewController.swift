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
        guard let type = wallet.address.addrType() else {
            return
        }
        
        var str = ""
        
        do {
            if isReciving {
                switch type {
                case .bech32:
                    str = wallet.address.uppercased()
                    addressLabel.text = str
                case .pub:
                    str = try PublicKey(xpub: wallet.address, network: Network.main, index: UInt32(wallet.accIndex.value!)).address
                    addressLabel.text = str
                case .bip49:
                    str = try PublicKey(xpub: wallet.address, network: Network.main, index: UInt32(wallet.accIndex.value!)).addressBIP49
                    addressLabel.text = str
                case .bip84:
                    str = try PublicKey(xpub: wallet.address, network: Network.main, index: UInt32(wallet.accIndex.value!)).addressBIP84.uppercased()
                    addressLabel.text = wallet.address
                case .p2pkh, .p2sh:
                    str = wallet.address
                    addressLabel.text = str
                }
            }else{
                if type == .bech32 {
                    str = wallet.address.uppercased()
                    addressLabel.text = wallet.address
                }else {
                    addressLabel.text = wallet.address
                    str = wallet.address
                }
            }
        } catch let err{
            print(err.localizedDescription)
        }

        print(str)
        let new = QRCode(str)
        qrImageView.image = new?.image
        
        nameLabel.text = wallet.name
    }
}
