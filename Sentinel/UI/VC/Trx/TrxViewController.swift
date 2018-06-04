//
//  TrxViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 04.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import SafariServices

class TrxViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let walletTransaction: WalletTransaction
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var idTextField: UITextView!
    
    init(walletTransaction: WalletTransaction) {
        self.walletTransaction = walletTransaction
        super.init(nibName: nil, bundle: nil)
        self.title = "Detail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if walletTransaction.value > 0 {
            amountLabel.text = "+\(walletTransaction.value.btc())"
        }else{
            amountLabel.text = "\(walletTransaction.value.btc())"
        }
        
        if walletTransaction.isConfirmed {
            statusLabel.text = "Confirmed"
            statusLabel.textColor = #colorLiteral(red: 0.3529411765, green: 0.8431372549, blue: 0.4156862745, alpha: 1)
        }else{
            statusLabel.text = "Pending"
        }
        
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        let x = abs(walletTransaction.value.btc())*7600
        valueLabel.text = fmt.string(from: NSNumber(value: Float(x)))! + " USD"
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm"
        
        dateLabel.text = df.string(from: Date(timeIntervalSince1970: TimeInterval(walletTransaction.time)))
        idTextField.text = walletTransaction.txid
        
        let web = UIBarButtonItem(image: UIImage(named: "Safari")!, style: .plain, target: self, action: #selector(openURL))
        self.navigationItem.rightBarButtonItems = [web]
    }
    
    @objc func openURL() {
        guard let url = URL(string: "https://m.oxt.me/transaction/\(walletTransaction.txid)") else {
            return
        }
        let safari = SFSafariViewController(url: url)
        safari.dismissButtonStyle = .close
        present(safari, animated: true, completion: nil)
    }
}
