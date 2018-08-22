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
    
    enum Mode {
        case set
        case confirm
        case login
        case remove
        
        var stringValue: String {
            switch self {
            case .set:
                return NSLocalizedString("NewPIN", comment: "")
            case .confirm:
                return NSLocalizedString("Confirm PIN", comment: "")
            case .login:
                return NSLocalizedString("Enter PIN", comment: "")
            case .remove:
                return NSLocalizedString("Remove PIN", comment: "")
            }
        }
    }
    
    let currentMode: Mode
    
    var nextItem: UIBarButtonItem!
    var prevHash: String?
    
    @IBOutlet var rootStackView: UIStackView!
    @IBOutlet var textField: UITextField!
    
    init(prevHash: String? = nil, mode: Mode) {
        self.prevHash = prevHash
        self.currentMode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var titles = "1234567890"
        rootStackView.subviews.forEach { (subStack) in
            (subStack as! UIStackView).subviews.forEach({ (sub) in
                if let sub = sub as? UIButton {
                    if sub.tag == 0 {
                        guard let number = titles.first else {
                            return
                        }
                        
                        let isScrambled = UserDefaults.standard.bool(forKey: "isScrambled")
                        if isScrambled {
                            let random = arc4random_uniform(UInt32(titles.count))
                            let char = titles[Int(random)]
                            titles.remove(at: titles.index(of: char!)!)
                            sub.setTitle(String(char!), for: UIControlState.normal)
                        }else{
                            sub.setTitle(String(number), for: UIControlState.normal)
                            titles = String(titles.dropFirst())
                        }
                        
                    } else if sub.tag == 1 {
                        sub.setTitle("delete", for: UIControlState.normal)

                    }
                }
            })
        }
        
        func setup() {
            self.title = currentMode.stringValue
            switch currentMode {
            case .set:
                nextItem = UIBarButtonItem(title: NSLocalizedString("Confirm", comment: ""), style: .plain, target: self, action: #selector(self.nextStep))
                nextItem.isEnabled = false
                self.navigationItem.rightBarButtonItems = [nextItem]
            case .confirm:
                nextItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(self.nextStep))
                nextItem.isEnabled = false
                self.navigationItem.rightBarButtonItems = [nextItem]
            case .login: break
            case .remove: break
            }
        }
        setup()
    }
    
    
    @objc func nextStep() {
        if (prevHash != nil) {
            // set password
            do {
                try Locksmith.saveData(data: ["pinCodeHash": prevHash!], forUserAccount: "account")
                UserDefaults.standard.set(true, forKey: "isScrambled")
                UserDefaults.standard.set(Date(), forKey: "lastPin")
                self.navigationController?.popToRootViewController(animated: true)
            }catch let err {
                print(err)
            }
        }else{
            let confirmVC = PincodeViewController(prevHash: tempPass, mode: .confirm)
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
        
        if currentMode == .login {
            guard let dictionary = Locksmith.loadDataForUserAccount(userAccount: "account") else { return }
            guard let savedPin = dictionary["pinCodeHash"] as? String else { return }
            if tempPass == savedPin {
                UserDefaults.standard.set(Date(), forKey: "lastPin")
                (self.navigationController as! RootNavigationViewController).showHome()
            }
        } else if currentMode == .remove {
            guard let dictionary = Locksmith.loadDataForUserAccount(userAccount: "account") else { return }
            guard let savedPin = dictionary["pinCodeHash"] as? String else { return }
            if tempPass == savedPin {
                try? Locksmith.deleteDataForUserAccount(userAccount: "account")
                UserDefaults.standard.removeObject(forKey: "lastPin")
                self.navigationController?.popViewController(animated: true)
            }
        } else {
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
