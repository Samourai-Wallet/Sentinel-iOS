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
        self.title = NSLocalizedString("Transaction", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let balanceStyle = Style {
            $0.font = UIFont.monospacedDigitSystemFont(ofSize: 40, weight: .regular)
        }
        
        let btcStyle = Style {
            $0.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .regular)
        }
        

        if walletTransaction.value > 0 {
            amountLabel.attributedText = "+\(walletTransaction.value.btc())".set(style: balanceStyle) + " BTC".set(style: btcStyle)
        }else{
            amountLabel.attributedText = "\(walletTransaction.value.btc())".set(style: balanceStyle) + " BTC".set(style: btcStyle)
        }
        
        statusLabel.text = walletTransaction.status()
        
        valueLabel.text = walletTransaction.value.price(isFiatForced: true).0 + " " + walletTransaction.value.price(isFiatForced: true).1
        
        let df = DateFormatter()
        df.locale = NSLocale.current
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
        if #available(iOS 11.0, *) {
            safari.dismissButtonStyle = .close
        } else {
            // Fallback on earlier versions
        }
        present(safari, animated: true, completion: nil)
    }
}
