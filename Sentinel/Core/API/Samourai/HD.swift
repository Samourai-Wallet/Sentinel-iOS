//
//  Multiaddr.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 31.05.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import Foundation

extension Samourai {
    struct HD: Codable {
        struct Wallet: Codable {
            let final_balance: Int
        }
        
        let wallet: Wallet
        
        struct Info: Codable {
            let latest_block: Samourai.Transaction.Block
        }

        let info: Info

        struct Address: Codable {
            let address: String
            let final_balance: Int
            let account_index: Int?
            let change_index: Int?
            let n_tx: Int
        }

        let addresses: [Address]

        let txs: [Trx]
    }
}
