//
//  BalanceViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import SwiftRichString
import RealmSwift

class BalanceViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let sentinel: Sentinel
    var wallet: Wallet?
    var notificationToken: NotificationToken? = nil
    @IBOutlet var balanceLabel: UILabel!
    
    init(sentinel: Sentinel, wallet: Wallet? = nil) {
        self.sentinel = sentinel
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationToken = sentinel.realm.objects(Wallet.self).observe({ (change) in
            self.updateBalance(wallet: self.wallet)
        })
    }
    
    func updateBalance(wallet: Wallet? = nil) {
        
        let balanceStyle = Style {
            $0.font = UIFont.robotoMono(size: 40)
        }
        
        let btcStyle = Style {
            $0.font = UIFont.robotoMono(size: 20)
        }
        
        guard sentinel.numberOfWallets > 0 else {
            balanceLabel.text = "--"
            return
        }
        
        if let wallet = wallet {
            guard let balance = wallet.balance.value?.btc() else { return }
            balanceLabel.attributedText = "\(balance)".set(style: balanceStyle) + "BTC".set(style: btcStyle)
        } else {
            balanceLabel.attributedText = "\(sentinel.totalBalance().btc())".set(style: balanceStyle) + "BTC".set(style: btcStyle)
        }
    }
}
