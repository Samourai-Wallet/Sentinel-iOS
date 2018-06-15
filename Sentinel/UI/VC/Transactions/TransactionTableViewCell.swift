//
//  TransactionTableViewCell.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var transaction: WalletTransaction!
    @IBOutlet var indicatorImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var walletNameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name(rawValue: "TogglePrice"), object: nil)
        
        UserDefaults.standard.bool(forKey: "isFiat")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = contentView.backgroundColor
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(priceTapped))
        valueLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setData(walletTransaction: WalletTransaction) {
        self.transaction = walletTransaction
        update()
    }
    
    @objc private func update() {
        if transaction.value < 0 {
            valueLabel.textColor = UIColor.white
            indicatorImageView.image = UIImage(named: "arrowOut")!
        } else {
            valueLabel.textColor = #colorLiteral(red: 0.3568627451, green: 0.8470588235, blue: 0.4117647059, alpha: 1)
            indicatorImageView.image = UIImage(named: "arrowIn")!
        }
        
        if UserDefaults.standard.bool(forKey: "isFiat") {
            valueLabel.text = "\((Float(abs(transaction.value).btc()*UserDefaults.standard.double(forKey: "Price")))) " + UserDefaults.standard.string(forKey: "PriceSourceCurrency")!.split(separator: " ").last!
        }else {
            valueLabel.text = "\(abs(transaction.value).btc()) BTC"
        }
        
        walletNameLabel.text = transaction.wallet?.name
        if transaction.conf == 3 {
            statusLabel.isHidden = true
        }else{
            statusLabel.isHidden = false
        }
        let date = Date(timeIntervalSince1970: TimeInterval(transaction.time))
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        timeLabel.text = df.string(from: date)
    }
    
    @objc func priceTapped() {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: "isFiat"), forKey: "isFiat")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "TogglePrice")))
    }
}
