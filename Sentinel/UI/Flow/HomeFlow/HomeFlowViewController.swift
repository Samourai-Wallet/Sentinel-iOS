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

class HomeFlowViewController: UIViewController, NewWalletViewControllerDelegate {
    
    let sentinel = Sentinel()
    
    var delegate: HomeFlowDelegate?
    var isEditingToggles = true
    
    @IBOutlet var balanceVCContainer: UIView!
    @IBOutlet var bottomMergedContainer: UIView!
    var bottomMergedVC: BottomMergedViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomMergedVC = BottomMergedViewController(sentinel: sentinel, homeFlowViewController: self)
        self.transition(to: bottomMergedContainer, duration: 0, child: bottomMergedVC, completion: nil)
        self.transition(to: self.balanceVCContainer, duration: 0, child: BalanceViewController(sentinel: sentinel), completion: nil)
                
        guard sentinel.numberOfWallets == 0 else {
            toggleBarItems()
            return
        }
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showNewAddress))
        let settings = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.plain, target: self, action: #selector(showSettings))
        self.navigationItem.rightBarButtonItems = [add]
        self.navigationItem.leftBarButtonItems = [settings]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func toggleBarItems() {
        if isEditingToggles {
            let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleBarItems))
            let settings = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.plain, target: self, action: #selector(showSettings))
            self.navigationItem.rightBarButtonItems = [edit]
            self.navigationItem.leftBarButtonItems = [settings]
            bottomMergedVC.animationContainer.isHidden = false
            bottomMergedVC.bottomScrollView.isScrollEnabled = true
        }else{
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showNewAddress))
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toggleBarItems))
            self.navigationItem.rightBarButtonItems = [add]
            self.navigationItem.leftBarButtonItems = [done]
            bottomMergedVC.animationContainer.isHidden = true
            bottomMergedVC.bottomScrollView.isScrollEnabled = false
        }
        
        isEditingToggles = !isEditingToggles
        bottomMergedVC.bottomScrollView.setContentOffset(CGPoint.zero, animated: true)
        delegate?.editStateChanged(isEditing: isEditingToggles)
    }
    
    @objc func showSettings() {
        let vc = UINavigationController(rootViewController: SettingsViewController(sentinel: sentinel))
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @objc func showNewAddress() {
        let vc = NewWalletViewController(sentinel: sentinel)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    func newAccontAdded() {
        update()
        guard sentinel.numberOfWallets == 1 else {
            return
        }

        toggleBarItems()
    }
    
    @objc func update() {
        sentinel.update()
    }
}
