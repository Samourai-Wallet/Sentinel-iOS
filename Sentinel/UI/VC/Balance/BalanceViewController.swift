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
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet var balanceLabel: UILabel!
    
    init(sentinel: Sentinel, wallet: Wallet? = nil) {
        self.sentinel = sentinel
        self.wallet = wallet
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
            $0.font = UIFont.robotoMono(size: 40)
        }
        
        let btcStyle = Style {
            $0.font = UIFont.robotoMono(size: 20)
        }
        
        guard sentinel.numberOfWallets > 0 else {
            balanceLabel.text = "--"
            return
        }
        
        let isFiat = UserDefaults.standard.bool(forKey: "isFiat")
        
        //REDO
        
        if let wallet = wallet {
            guard let balance = wallet.balance.value?.btc() else {
                balanceLabel.text = "--"
                return
            }
            
            if isFiat {
                balanceLabel.attributedText = "\((Float(abs(balance)*UserDefaults.standard.double(forKey: "Price"))))".set(style: balanceStyle) + String(UserDefaults.standard.string(forKey: "PriceSourceCurrency")!.split(separator: " ").last!).set(style: btcStyle)
            }else{
                balanceLabel.attributedText = "\(balance)".set(style: balanceStyle) + "BTC".set(style: btcStyle)
            }
        } else {
            if isFiat {
                balanceLabel.attributedText = "\((Float(abs(sentinel.totalBalance()).btc()*UserDefaults.standard.double(forKey: "Price"))))".set(style: balanceStyle) + String(UserDefaults.standard.string(forKey: "PriceSourceCurrency")!.split(separator: " ").last!).set(style: btcStyle)
            }else{
                balanceLabel.attributedText = "\(sentinel.totalBalance().btc())".set(style: balanceStyle) + "BTC".set(style: btcStyle)
            }
        }
    }
    
    @objc func priceTapped() {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: "isFiat"), forKey: "isFiat")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "TogglePrice")))
    }
}
