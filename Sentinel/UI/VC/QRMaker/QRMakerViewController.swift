//
//  QRMakerViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 04.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class QRMakerViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }

    let wallet: Wallet
    @IBOutlet var qrImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!

    init(wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        self.title = "Deposit Address"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var str = wallet.address
        if wallet.address.addrType() == .bech32 {
            str = wallet.address.uppercased()
        }
        
        let new = QRCode(str)
        qrImageView.image = new?.image
        
        addressLabel.text = wallet.address
        nameLabel.text = wallet.name
    }
}
