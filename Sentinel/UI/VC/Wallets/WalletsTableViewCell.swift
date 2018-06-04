//
//  WalletsTableViewCell.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class WalletsTableViewCell: UITableViewCell {
//    var wallet: Wallet?
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addrLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    
    func setData(wallet: Wallet) {
        nameLabel.text = wallet.name
        addrLabel.text = wallet.address
        
        if let balance = wallet.balance.value {
            balanceLabel.text = "\(balance.btc())"
        }else{
            balanceLabel.text = "-"
        }
    }
}
