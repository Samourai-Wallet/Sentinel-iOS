//
//  PincodeViewController.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 6/8/18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import UIKit
import Locksmith

class PincodeViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }
    
    var isScrambled: Bool? = false
    @IBOutlet var rootStackView: UIStackView!
    @IBOutlet var textField: UITextField!
    var nextItem: UIBarButtonItem!
    
    var prevHash: String?
    var isLogin: Bool? = false
    
    init(prevHash: String? = nil, isLogin: Bool? = false, isScrambled: Bool? = false) {
        self.prevHash = prevHash
        self.isLogin = isLogin
        self.isScrambled = isScrambled
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var titles = "1234567890"
        rootStackView.subviews.forEach { (subStack) in
            (subStack as! UIStackView).subviews.forEach({ (sub) in
                if let sub = sub as? UIButton {
                    if let number = titles.first {
                        if isScrambled! {
                            let random = arc4random_uniform(UInt32(titles.count))
                            let char = titles[Int(random)]
                            titles.remove(at: titles.index(of: char!)!)
                            sub.setTitle(String(char!), for: UIControlState.normal)
                        }else{
                            sub.setTitle(String(number), for: UIControlState.normal)
                            titles = String(titles.dropFirst())
                        }
                    }else {
                        sub.setTitle("delete", for: UIControlState.normal)
                    }
                }
            })
        }
        
        self.title = "Enter PIN"
        guard !isLogin! else {
            return
        }
        
        if (prevHash != nil) {
            self.title = "Confirm PIN"
            nextItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.nextStep))
        }else {
            nextItem = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(self.nextStep))
            self.title = "New PIN"
        }
        
        nextItem.isEnabled = false
        self.navigationItem.rightBarButtonItems = [nextItem]
    }
    
    
    @objc func nextStep() {
        if (prevHash != nil) {
            // set password
            do {
                try Locksmith.deleteDataForUserAccount(userAccount: "account")
                try Locksmith.saveData(data: ["pinCodeHash": prevHash!], forUserAccount: "account")
                UserDefaults.standard.set(Date(), forKey: "lastPin")
                self.navigationController?.popToRootViewController(animated: true)
            }catch let err {
                print(err)
            }
        }else{
            let confirmVC = PincodeViewController(prevHash: tempPass)
            show(confirmVC, sender: self)
        }
    }
    
    var tempPass = ""
    @IBAction func buttonDidTap(_ sender: UIButton) {
        if sender.titleLabel?.text == "delete" {
            tempPass = String(tempPass.dropLast())
            textField.deleteBackward()
        }else{
            textField.insertText("•")
            tempPass += sender.titleLabel!.text!
        }
        
        if isLogin! {
            // check and let in
            guard let dictionary = Locksmith.loadDataForUserAccount(userAccount: "account") else { return }
            guard let savedPin = dictionary["pinCodeHash"] as? String else { return }
            if tempPass == savedPin {
                (self.navigationController as! RootNavigationViewController).showHome()
            }
        }else{
            if tempPass.count < 9 && tempPass.count > 4 {
                nextItem.isEnabled = true
            }else{
                nextItem.isEnabled = false
            }
            
            guard let prevHash = prevHash else {
                return
            }
            if prevHash == tempPass {
                nextItem.isEnabled = true
            }else{
                nextItem.isEnabled = false
            }
        }
    }
}
