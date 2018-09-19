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
    
    var loaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationBar.tintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = #colorLiteral(red: 0.2823529412, green: 0.3098039216, blue: 0.3411764706, alpha: 1)
        navigationBar.backgroundColor = #colorLiteral(red: 0.2823529412, green: 0.3098039216, blue: 0.3411764706, alpha: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkForPin), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.cover), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        guard (Locksmith.loadDataForUserAccount(userAccount: "account") != nil) else {
            
            showHome()
            return
        }
        showPIN()
    }
    
    @objc func checkForPin() {
        guard (Locksmith.loadDataForUserAccount(userAccount: "account") != nil), let lastPin = UserDefaults.standard.value(forKey: "lastPin") as? Date, Int(Date().timeIntervalSince(lastPin)) < 900, loaded else {
            showPIN()
            return
        }
        
        showHome()
    }
    
    lazy var homeVC: HomeFlowViewController = {
        return HomeFlowViewController()
    }()
    
    func showHome() {
        loaded = true
        self.viewControllers = [homeVC]
    }
    
    @objc func cover() {
        self.viewControllers = [CoverViewController(bg: viewControllers.first!.view.snapshotView(afterScreenUpdates: true)!)]
    }
    
    func showPIN() {
        self.viewControllers = [PincodeViewController(mode: .login)]
    }
}
