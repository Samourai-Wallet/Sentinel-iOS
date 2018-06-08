//
//  Wallet.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import RealmSwift

class Wallet: Object {
    @objc dynamic var address = ""
    @objc dynamic var name = ""
    let balance = RealmOptional<Int>()
    let accIndex = RealmOptional<Int>()
    
    var addrType: AddressType? {
        return address.addrType()
    }
    
    var raw: [String: Any] {
        var rawDic: [String: Any] = [:]
        rawDic["address"] = address
        rawDic["name"] = name
        if let index = self.accIndex.value {
            rawDic["receiveIdx"] = index
        }
        return rawDic
    }
    
    override static func primaryKey() -> String? {
        return "address"
    }
}
