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
    
    var walletAddress: String? = nil
    var notificationToken: NotificationToken? = nil
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet var balanceLabel: UILabel!
    
    init(sentinel: Sentinel, walletAddress: String? = nil) {
        self.sentinel = sentinel
        self.walletAddress = walletAddress
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationToken = sentinel.realm.objects(Wallet.self).observe({ (change) in
            self.updateBalance()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBalance), name: Notification.Name(rawValue: "TogglePrice"), object: nil)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(priceTapped))
        balanceLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func updateBalance() {
        
        let balanceStyle = Style {
            $0.font = UIFont.monospacedDigitSystemFont(ofSize: 40, weight: .regular)
        }
        
        let btcStyle = Style {
            $0.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .regular)
        }
        
        guard sentinel.numberOfWallets > 0 else {
            balanceLabel.text = "--"
            return
        }
                
        let realm = try! Realm()
        if let walletAddress = walletAddress, let wallet = realm.objects(Wallet.self).filter("address == %@", walletAddress).first{
            guard (wallet.balance.value?.btc()) != nil else {
                balanceLabel.text = "--"
                return
            }
            
            balanceLabel.attributedText = wallet.balance.value!.price().0 + " " + wallet.balance.value!.price().1.set(style: btcStyle)
        } else {
            balanceLabel.attributedText = sentinel.totalBalance().price().0.set(style: balanceStyle) + " " + sentinel.totalBalance().price().1.set(style: btcStyle)
        }
    }
    
    @objc func priceTapped() {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: "isFiat"), forKey: "isFiat")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "TogglePrice")))
    }
}
