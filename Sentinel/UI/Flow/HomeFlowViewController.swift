//
//  HomeFlowViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import Moya

protocol HomeFlowDelegate {
    func editStateChanged(isEditing: Bool)
}

class HomeFlowViewController: UIViewController {
    @IBOutlet var balanceVCContainer: UIView!
    @IBOutlet var transactionsVCContainer: UIView!
    
    let sentinel = Sentinel()
    var delegate: HomeFlowDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transition(to: transactionsVCContainer, duration: 0, child: BottomMergedViewController(sentinel: sentinel, homeFlowViewController: self), completion: nil)
        self.transition(to: self.balanceVCContainer, duration: 0, child: BalanceViewController(sentinel: sentinel), completion: nil)
        sentinel.update()
        
        toggleBarItems()
    }
    
    @IBAction func newWalletAction(_ sender: UIBarButtonItem) {

    }
    
    var isEditingToggles = true
    @objc func toggleBarItems() {
        if isEditingToggles {
            let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleBarItems))
            let settings = UIBarButtonItem(image: UIImage(named: "Settings")!, style: .plain, target: self, action: #selector(showSettings))
            self.navigationItem.rightBarButtonItems = [edit]
            self.navigationItem.leftBarButtonItems = [settings]
        }else{
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showNewAddress))
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toggleBarItems))
            self.navigationItem.rightBarButtonItems = [add]
            self.navigationItem.leftBarButtonItems = [done]
        }
        
        isEditingToggles = !isEditingToggles
        delegate?.editStateChanged(isEditing: isEditingToggles)
    }
    
    @objc func showSettings() {
        let vc = SettingsViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @objc func showNewAddress() {
        let vc = NewWalletViewController(sentinel: sentinel)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
}
