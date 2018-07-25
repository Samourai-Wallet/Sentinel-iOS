//
//  RootNavigationViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 6/8/18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import Locksmith

class RootNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationBar.tintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = #colorLiteral(red: 0.4220947623, green: 0.4648562074, blue: 0.5403060317, alpha: 1)
        navigationBar.backgroundColor = #colorLiteral(red: 0.4220947623, green: 0.4648562074, blue: 0.5403060317, alpha: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkForPin), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.cover), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        guard (Locksmith.loadDataForUserAccount(userAccount: "account") != nil) else {
            
            showHome()
            return
        }
        showPIN()
    }
    
    var loaded = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if loaded {
            checkForPin()
        }else {
            loaded = true
        }
    }
    
    @objc func checkForPin() {
        guard (Locksmith.loadDataForUserAccount(userAccount: "account") != nil), let lastPin = UserDefaults.standard.value(forKey: "lastPin") as? Date, Int(Date().timeIntervalSince(lastPin)) > 900 else {
            showHome()
            return
        }
        
        showPIN()
    }
    
    lazy var homeVC: HomeFlowViewController = {
        return HomeFlowViewController()
    }()
    
    func showHome() {
        self.viewControllers = [homeVC]
    }
    
    @objc func cover() {
        self.viewControllers = [CoverViewController(bg: viewControllers.first!.view.snapshotView(afterScreenUpdates: true)!)]
    }
    
    func showPIN() {
        self.viewControllers = [PincodeViewController(mode: .login)]
    }
}
