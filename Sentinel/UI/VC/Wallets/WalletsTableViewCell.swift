//
//  WalletsTableViewCell.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class WalletsTableViewCell: UITableViewCell {
    
    var wallet: Wallet!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addrLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleAndUpdate), name: Notification.Name(rawValue: "TogglePrice"), object: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = contentView.backgroundColor
    }
    
    func setData(wallet: Wallet) {
        self.wallet = wallet
        update()
    }
    
    @objc func toggleAndUpdate() {
        self.update()
    }
    
    func update() {
        nameLabel.text = wallet.name
        addrLabel.text = wallet.address
        
        if let balance = wallet.balance.value {
            balanceLabel.text = balance.price().0
            currencyLabel.text = balance.price().1
        }else{
            balanceLabel.text = "-"
        }
    }
}
