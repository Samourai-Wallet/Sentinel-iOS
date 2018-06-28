//
//  WalletTransaction.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 03.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import RealmSwift

class WalletTransaction: Object {
    
    @objc dynamic var conf = 0
    @objc dynamic var time = 0
    @objc dynamic var value = 0
    @objc dynamic var txid = ""
    @objc dynamic var wallet: Wallet? = nil
    
    override static func primaryKey() -> String? {
        return "txid"
    }
    
    func status() -> String {
        guard conf < 3 else {
            return "Confirmed"
        }
        
        return "Pending \(conf)/3"
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let compareable = object as? WalletTransaction else {
            return false
        }
        
        return self.conf == compareable.conf &&
            self.time == compareable.time &&
            self.value == compareable.value &&
            self.txid == compareable.txid &&
            self.wallet == compareable.wallet
    }
}
