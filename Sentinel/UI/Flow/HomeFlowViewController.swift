//
//  HomeFlowViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import Moya

class HomeFlowViewController: UIViewController {
    @IBOutlet var balanceVCContainer: UIView!
    @IBOutlet var transactionsVCContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transition(to: transactionsVCContainer, duration: 0, child: BottomMergedViewController(), completion: nil)
        self.transition(to: self.balanceVCContainer, duration: 0, child: BalanceViewController(balance: 23232), completion: nil)
    }
    
    @IBAction func newWalletAction(_ sender: UIBarButtonItem) {
        let vc = NewWalletViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
}
