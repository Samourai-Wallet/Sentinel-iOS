//
//  TransactionTableViewCell.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import RealmSwift

class TransactionTableViewCell: UITableViewCell {
    
    var walletTransactionID: String? = ""
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
    
    func setData(walletTransactionID: String? = nil) {
        self.walletTransactionID = walletTransactionID
        update()
    }
    
    @objc private func update() {
        
        let realm = try! Realm()
        guard let trxID = walletTransactionID, let transaction = realm.objects(WalletTransaction.self).filter("txid == %@", trxID).first else {
            return
        }
        
        if transaction.value < 0 {
            valueLabel.textColor = UIColor.white
            indicatorImageView.image = UIImage(named: "arrowOut")!
        } else {
            valueLabel.textColor = #colorLiteral(red: 0.3568627451, green: 0.8470588235, blue: 0.4117647059, alpha: 1)
            indicatorImageView.image = UIImage(named: "arrowIn")!
        }
        
        valueLabel.text = transaction.value.price().0 + " " + transaction.value.price().1
        
        walletNameLabel.text = transaction.wallet?.name
        if transaction.conf == 3 {
            statusLabel.isHidden = true
        }else{
            statusLabel.isHidden = false
        }
        let date = Date(timeIntervalSince1970: TimeInterval(transaction.time))
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        df.locale = NSLocale.current
        timeLabel.text = df.string(from: date)
    }
}
