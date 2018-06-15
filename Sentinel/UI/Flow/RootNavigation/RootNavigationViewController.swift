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
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkForPin), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        checkForPin()
        UserDefaults.standard.set(false, forKey: "isFiat")
    }
    
    @objc func checkForPin() {
        guard (Locksmith.loadDataForUserAccount(userAccount: "account") != nil), let lastPin = UserDefaults.standard.value(forKey: "lastPin") as? Date else {
            showHome()
            return
        }
        if Int(Date().timeIntervalSince(lastPin)) > 900 {
            self.viewControllers = [PincodeViewController(mode: .login)]
        }else{
            showHome()
        }
    }
    
    func showHome() {
        self.viewControllers = [self.storyboard!.instantiateViewController(withIdentifier: "home")]
    }
}
