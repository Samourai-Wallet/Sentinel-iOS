//
//  WalletViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 03.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import HDWalletKit

class WalletViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    let sentinel: Sentinel
    let wallet: Wallet
    
    @IBOutlet var balanceContainer: UIView!
    @IBOutlet var transactionsContainer: UIView!
    
    init(sentinel: Sentinel, wallet: Wallet) {
        self.sentinel = sentinel
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        self.title = wallet.name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transition(to: balanceContainer, duration: 0, child: BalanceViewController(sentinel: sentinel, walletAddress: wallet.address), completion: nil)
        transition(to: transactionsContainer, duration: 0, child: TransactionsViewController(sentinel: sentinel, wallet: wallet), completion: nil)
    }
    
    @IBAction func showReciving(_ sender: UIButton) {
        let qrVC = QRMakerViewController(wallet: wallet, isReciving: true)
        show(qrVC, sender: self)
    }
}
