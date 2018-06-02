//
//  NewWalletViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit


class NewWalletViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
