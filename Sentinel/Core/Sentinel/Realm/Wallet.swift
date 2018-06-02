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
    @objc dynamic var balance = 0
    @objc dynamic var n_tx = 0
}
