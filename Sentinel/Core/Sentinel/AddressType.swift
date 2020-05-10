//
//  AddressType.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 02.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import Foundation
import PromiseKit
import HDWalletKit

enum AddressType: String {
    case pub
    case bip49
    case bip84
    case p2pkh
    case p2sh
    case bech32
}

extension String {
    
    func addrType() -> AddressType? {
        
        guard let base58DecodedBytes = self.base58CheckDecodedBytes else {
            if self.isValidBech32() {
                return .bech32
            }
            return nil
        }
        
        let lenght = base58DecodedBytes.count
        let value = UInt32(bigEndian: base58DecodedBytes.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
            }.pointee)
        
        if lenght == 78 {
            switch value {
            case Network.main.publicKeyVersion:
                return .pub
            case Network.main.publicKeyBIP49Version:
                return .bip49
            case Network.main.publicKeyBIP84Version:
                return .bip84
            default:
                return nil
            }
        } else {
            guard let firstByte = base58DecodedBytes.first else {
                return nil
            }
            switch firstByte {
            case Network.main.publicKeyHash:
                return .p2pkh
            case Network.main.scriptHash:
                return .p2sh
            default:
                return nil
            }
        }
        
    }
    
    func isValidBech32() -> Bool {
        let xx = SegwitAddrCoder()
        do {
            _ = try xx.decode(hrp: Network.main.bech32, addr: self)
            return true
        } catch {
            return false
        }
    }
}
