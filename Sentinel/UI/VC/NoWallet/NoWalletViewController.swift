//
//  NoWallet.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit

protocol NoWalletViewControllerDelegate {
    func NewWalletTapped()
}

class NoWalletViewController: UIViewController {
    var delegate: NoWalletViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) { fatalError("...") }

    @IBAction func newWalletAction(_ sender: Any) {
        delegate?.NewWalletTapped()
    }
}
