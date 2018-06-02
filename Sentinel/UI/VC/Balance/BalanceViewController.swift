//
//  BalanceViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import SwiftRichString

class BalanceViewController: UIViewController {
    @IBOutlet var balanceLabel: UILabel!
    let balance: Int
    
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    init(balance: Int) {
        self.balance = balance
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let balanceStyle = Style {
            $0.font = UIFont.roboto(weight: UIFont.Weight.heavy, size: 40)
        }
        
        let btcStyle = Style {
            $0.font = UIFont.roboto(weight: UIFont.Weight.heavy, size: 20)
        }
        
        balanceLabel.attributedText = "\(balance.btc())".set(style: balanceStyle) + "BTC".set(style: btcStyle)
    }
}
