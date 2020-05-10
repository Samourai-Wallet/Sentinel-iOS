//
//  Unspent.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 31.05.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import Foundation

extension Samourai {
    
    struct Unspent {
        
        struct Output {
            let tx_hash: String
            let tx_output_n: Int
            let tx_version: Int
            let tx_locktime: Int
            let value: Int
            let script: String
            let confirmations: Int
            let xpub: Xpub
        }
        
        let unspent_outputs: [Unspent.Output]
    }
}
