//
//  TransactionTableViewCell.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet var indicatorImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var walletNameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = contentView.backgroundColor
    }
    
    func setData(walletTransaction: WalletTransaction) {
        
        if walletTransaction.value < 0 {
            valueLabel.textColor = UIColor.white
            indicatorImageView.image = UIImage(named: "arrowOut")!
        } else {
            valueLabel.textColor = #colorLiteral(red: 0.3568627451, green: 0.8470588235, blue: 0.4117647059, alpha: 1)
            indicatorImageView.image = UIImage(named: "arrowIn")!
        }
        
        valueLabel.text = "\(abs(walletTransaction.value).btc())"
        walletNameLabel.text = walletTransaction.wallet?.name
        if walletTransaction.conf == 3 {
            statusLabel.isHidden = true
        }else{
            statusLabel.isHidden = false
        }
        let date = Date(timeIntervalSince1970: TimeInterval(walletTransaction.time))
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        timeLabel.text = df.string(from: date)
    }
}
