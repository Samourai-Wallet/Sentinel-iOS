//
//  Transaction.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 31.05.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import Foundation

extension Samourai {
    
    struct Transaction: Codable {
        let txid: String
        let size: Int
        let vsize: Int
        let version: Int
        let locktime: Int
        
        struct Block: Codable {
            let height: Int
            let hash: String
            let time: Int
        }
        
        let block: Block
        
        struct Input: Codable {
            struct Outpoint: Codable {
                let txid: String
                let vout: Int
                let value: Int
                let scriptpubkey: String
            }
            
            let n: Int
            let outpoint: Outpoint
            let sig: String
            let seq: Int
        }
        
        let inputs: [Input]
        
        struct Output: Codable {
            let n: Int
            let value: Int
            let scriptpubkey: String
            let type: String
            let address: String
        }
        
        let outputs: [Output]
    }
}
