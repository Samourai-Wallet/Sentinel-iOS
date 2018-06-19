//
//  WalletsTableViewCell.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class WalletsTableViewCell: UITableViewCell {
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var wallet: Wallet!
    var fiatPrice = false
    
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
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(priceTapped))
        balanceLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setData(wallet: Wallet) {
        self.wallet = wallet
        update()
    }
    
    @objc func toggleAndUpdate() {
        self.fiatPrice = !self.fiatPrice
        self.update()
    }
    
    func update() {
        nameLabel.text = wallet.name
        addrLabel.text = wallet.address
        
        if let balance = wallet.balance.value {
            if fiatPrice {
                balanceLabel.text = "\((Float(balance.btc()*UserDefaults.standard.double(forKey: "Price"))))"
                currencyLabel.text = String(UserDefaults.standard.string(forKey: "PriceSourceCurrency")!.split(separator: " ").last!)
            }else{
                balanceLabel.text = "\(balance.btc())"
                currencyLabel.text = "BTC"
            }
        }else{
            balanceLabel.text = "-"
        }
    }
    
    @objc func priceTapped() {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: "isFiat"), forKey: "isFiat")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "TogglePrice")))
    }
}
