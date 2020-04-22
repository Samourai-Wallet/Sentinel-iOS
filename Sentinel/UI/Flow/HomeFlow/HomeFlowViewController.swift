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
        let settings = UIBarButtonItem(title: NSLocalizedString("Settings", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(showSettings))
        let network = UIBarButtonItem.menuButton(self, action: #selector(showNetworkSettings), imageName: "network")
        self.navigationItem.rightBarButtonItems = [add, network]
        self.navigationItem.leftBarButtonItems = [settings]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTorInitIfEnabled()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func toggleBarItems() {
        let network = UIBarButtonItem.menuButton(self, action: #selector(showNetworkSettings), imageName: "network")
        if isEditingToggles {
            let edit = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(toggleBarItems))
            let settings = UIBarButtonItem(title: NSLocalizedString("Settings", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(showSettings))
            self.navigationItem.rightBarButtonItems = [edit, network]
            self.navigationItem.leftBarButtonItems = [settings]
            bottomMergedVC.animationContainer.isHidden = false
            bottomMergedVC.bottomScrollView.isScrollEnabled = true
        }else{
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showNewAddress))
            let done = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(toggleBarItems))
            self.navigationItem.rightBarButtonItems = [add, network]
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
    
    @objc func showNetworkSettings() {
        let vc = UINavigationController(rootViewController: NetworkViewController())
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    func showTorInitIfEnabled() {
        if let isTorEnabled = UserDefaults.standard.value(forKey: "isTorEnabled") as? Bool {
            if isTorEnabled {
                let initTorVC = InitializingTorViewController()
                self.present(initTorVC, animated: false, completion: nil)
            } else {
                NSLog("TOR disabled in user defaults.")
            }
        }
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
