//
//  Trx.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import Foundation

extension Samourai {
    struct Trx: Codable {
        let hash: String
        let time: Int
        let version: Int
        let locktime: Int
        let result: Int
        let block_height: Int?
        let balance: Int
        
        struct Input: Codable {
            let vin: Int
            let sequence: Int
            
            struct PrevOut: Codable {
                let txid: String
                let vout: Int
                let value: Int
                let addr: String
                
                let xpub: Xpub?
            }
            
            let prev_out: PrevOut
        }
        
        let inputs: [Input]
        
        struct Output: Codable {
            let n: Int
            let value: Int
            let addr: String
            let xpub: Xpub?
        }
        
        let out: [Output]
    }
}
