//
//  Sentinel.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 01.06.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift
import Moya

class Sentinel {
    
    let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
    let samouraiAPI = MoyaProvider<Samourai>()
    
    enum Errors: Error {
        case unvalidAddres
        case walletNameAlreadyDup
        case walletAdressAlreadyDup
        case noName
        case noAddress
    }
    
    func addWallet(name: String?, addr: String?) -> Promise<Void> {
        return Promise<Void> { seal in
            
            guard let name = name else {
                seal.reject(Errors.noName)
                return
            }
            
            guard let addr = addr?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                seal.reject(Errors.noAddress)
                return
            }
            
            guard name.count > 0 else {
                seal.reject(Errors.noName)
                return
            }
            
            guard addr.count > 0 else {
                seal.reject(Errors.noAddress)
                return
            }
            
            guard isValidWalletName(name: name) else {
                seal.reject(Errors.walletAdressAlreadyDup)
                return
            }
            
            guard isValidWalletAddr(address: addr) else {
                seal.reject(Errors.walletAdressAlreadyDup)
                return
            }
            
            guard (addr.addrType() != nil) else {
                seal.reject(Errors.unvalidAddres)
                return
            }
            
            
            let newWallet = Wallet()
            newWallet.name = name
            newWallet.address = addr
            
            do {
                try realm.write {
                    realm.add(newWallet)
                    seal.fulfill(())
                    update()
                }
            } catch let err {
                seal.reject(err)
            }
        }
    }
    
    private func isValidWalletName(name: String) -> Bool {
        let count = realm.objects(Wallet.self).filter(NSPredicate(format: "name == %@", name)).count
        if count == 0 { return true }
        return false
    }
    
    private func isValidWalletAddr(address: String) -> Bool {
        let count = realm.objects(Wallet.self).filter(NSPredicate(format: "address == %@", address)).count
        if count == 0 { return true }
        return false
    }
}

extension Sentinel {
    func update() {
        getHD().then { (hd) -> Promise<Samourai.HD> in
            return self.updateRealm(hd: hd)
            }.then({ (hd) -> Promise<Void> in
                return self.updateTransactions(hd: hd)
            }).done { () in
                print("finished")
            }.catch { (err) in
                print(err.localizedDescription)
        }
    }
    
    func getHD() -> Promise<Samourai.HD> {
        var actives: [String] = []
        let addresses = realm.objects(Wallet.self)
        addresses.forEach { (wallet) in
            actives.append(wallet.address)
        }
        return samouraiAPI.requestDecoded(target: Samourai.multiaddr(active: actives, new: nil, bip49: nil, bip84: nil), type: Samourai.HD.self)
    }
    
    func updateRealm(hd: Samourai.HD) -> Promise<Samourai.HD> {
        return Promise<Samourai.HD> { seal in
            hd.addresses.forEach { (yWallet) in
                guard let wallet = realm.objects(Wallet.self).filter(NSPredicate(format: "address == %@", yWallet.address)).first else { return }
                
                do {
                    try realm.write {
                        print(yWallet.final_balance)
                        wallet.balance.value = yWallet.final_balance
                    }
                } catch let err {
                    seal.reject(err)
                }
            }
            seal.fulfill(hd)
        }
    }
    
    func updateTransactions(hd: Samourai.HD) -> Promise<Void> {
        return Promise<Void> { seal in
            
            hd.txs.forEach { (transaction) in
                let wTransaction = WalletTransaction()
                wTransaction.txid = transaction.hash
                wTransaction.value = transaction.result
                wTransaction.time = transaction.time
                if (transaction.block_height != nil) {
                    wTransaction.isConfirmed = true
                }
                
                transaction.inputs.forEach({ (input) in
                    var addrToCheck = ""
                    if let xpub = input.prev_out.xpub?.m {
                        addrToCheck = xpub
                    }else{
                        addrToCheck = input.prev_out.addr
                    }
                    
                    if let wallet = realm.objects(Wallet.self).filter(NSPredicate(format: "address == %@", addrToCheck)).first {
                        wTransaction.wallet = wallet
                    }
                })
                
                transaction.out.forEach({ (output) in
                    var addrToCheck = ""
                    if let xpub = output.xpub?.m {
                        addrToCheck = xpub
                    }else{
                        addrToCheck = output.addr
                    }
                    
                    if let wallet = realm.objects(Wallet.self).filter(NSPredicate(format: "address == %@", addrToCheck)).first {
                        wTransaction.wallet = wallet
                    }
                })
                
                do {
                    try realm.write {
                        realm.add(wTransaction, update: true)
                    }
                } catch let err {
                    seal.reject(err)
                }
            }
            seal.fulfill(())
        }
    }
}

extension Sentinel {
    var numberOfWallets: Int {
        return realm.objects(Wallet.self).count
    }
    
    func wallet(forRow row: Int) -> Wallet {
        return realm.objects(Wallet.self)[row]
    }
    
    var numberOfTransactions: Int {
        return realm.objects(WalletTransaction.self).count
    }
    
    func wallet(forRow row: Int) -> WalletTransaction {
        return realm.objects(WalletTransaction.self)[row]
    }
    
    func totalBalance() -> Int {
        var total = 0
        realm.objects(Wallet.self).forEach { (wallet) in
            if let value = wallet.balance.value {
                total += value
            }
        }
        return total
    }
}
