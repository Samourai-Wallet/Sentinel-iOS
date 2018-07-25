//
//  TransactionTableViewCell.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    var transaction: WalletTransaction!
    @IBOutlet var indicatorImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var walletNameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name(rawValue: "TogglePrice"), object: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = contentView.backgroundColor
    }
    
    func setData(walletTransaction: WalletTransaction) {
        self.transaction = walletTransaction
        update()
    }
    
    @objc private func update() {
        
        //REDO
        
        if transaction.value < 0 {
            valueLabel.textColor = UIColor.white
            indicatorImageView.image = UIImage(named: "arrowOut")!
        } else {
            valueLabel.textColor = #colorLiteral(red: 0.3568627451, green: 0.8470588235, blue: 0.4117647059, alpha: 1)
            indicatorImageView.image = UIImage(named: "arrowIn")!
        }
        
        if UserDefaults.standard.bool(forKey: "isFiat") {
            valueLabel.text = "\((Float((round(100*abs(transaction.value).btc()*UserDefaults.standard.double(forKey: "Price"))/100)))) " + UserDefaults.standard.string(forKey: "PriceSourceCurrency")!.split(separator: " ").last!
        }else {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let finalNumber = numberFormatter.number(from: "\(abs(transaction.value).btc())")
            valueLabel.text = "\(finalNumber!) BTC"
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
}
