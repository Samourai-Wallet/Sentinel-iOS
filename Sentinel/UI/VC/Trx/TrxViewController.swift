//
//  TrxViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 04.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import SafariServices
import SwiftRichString

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
        self.title = "Transaction"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let balanceStyle = Style {
            $0.font = UIFont.robotoMono(size: 40)
        }
        
        let btcStyle = Style {
            $0.font = UIFont.robotoMono(size: 20)
        }
        

        if walletTransaction.value > 0 {
            amountLabel.attributedText = "+\(walletTransaction.value.btc())".set(style: balanceStyle) + " BTC".set(style: btcStyle)
        }else{
            amountLabel.attributedText = "\(walletTransaction.value.btc())".set(style: balanceStyle) + " BTC".set(style: btcStyle)
        }
        
        statusLabel.text = walletTransaction.status()
        
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
