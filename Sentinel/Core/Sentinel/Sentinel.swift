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
import CryptoSwift
import Starscream
import UserNotifications
import Reachability

class Sentinel {
    
    let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
    let streetPriceAPI = MoyaProvider<StreetPrice>()
    let socket = WebSocket(url: URL(string: "wss://api.samourai.io/v2/inv")!)
    let reachability = Reachability()!

    enum Errors: Error, LocalizedError {
        case unvalidAddres
        case walletNameAlreadyDup
        case walletAdressAlreadyDup
        case noName
        case noAddress
        case noPrice
        case nothingToExport
        case failedToExport
        case failedToImport
        
        public var errorDescription: String? {
            switch self {
            case .unvalidAddres:
                return "The entered address is not valid"
            case .walletNameAlreadyDup:
                return "This wallet name is already in use"
            case .walletAdressAlreadyDup:
                return "This address has been already added"
            case .noName:
                return "Please enter a name"
            case .noAddress:
                return "Please enter a address"
            case .noPrice:
                return "Failed to obtain stree price"
            case .nothingToExport:
                return "You have no account to export"
            case .failedToExport:
                return "Failed export the wallet"
            case .failedToImport:
                return "Failed import the wallet"
            }
        }
    }
    
    init() {
        socket.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        NotificationCenter.default.addObserver(self, selector: #selector(self.fup), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        try? self.reachability.startNotifier()
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
                    realm.add(newWallet, update: true)
                    seal.fulfill(())
                }
            } catch let err {
                seal.reject(err)
            }
        }
    }
    
    func renameWallet(wallet: Wallet, name: String?) -> Promise<Void> {
        return Promise<Void> { seal in
            
            guard let name = name else {
                seal.reject(Errors.noName)
                return
            }
            
            do {
                try realm.write {
                    wallet.name = name
                    realm.add(wallet, update: true)
                    seal.fulfill(())
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
    
    @discardableResult
    func update() -> Promise<Void> {
        return Promise<Void> { seal in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            guard numberOfWallets > 0 else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                seal.fulfill(())
                return
            }
            
            updatePrice().then { () -> Promise<Samourai.HD> in
                return self.getHD()
                }.then { (hd) -> Promise<Samourai.HD> in
                    return self.updateRealm(hd: hd)
                }.then({ (hd) -> Promise<Void> in
                    return self.updateTransactions(hd: hd)
                }).done { () in
                    seal.fulfill(())
                }.catch { (err) in
                    print(err.localizedDescription)
                    seal.reject(err)
                }.finally {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if !self.socket.isConnected && UIApplication.shared.applicationState == .active {
                        self.socket.connect()
                    }
            }
        }
    }
    
    @objc func fup() {
        self.update()
    }
    
    func getHD() -> Promise<Samourai.HD> {
        var actives: [String] = []
        let addresses = realm.objects(Wallet.self)
        
        addresses.forEach { (wallet) in
            actives.append(wallet.address)
        }
        
        let samouraiAPI = MoyaProvider<Samourai>(session: TorManager.shared.sessionHandler.session())
        return samouraiAPI.requestDecoded(target: Samourai.multiaddr(active: actives, new: nil, bip49: nil, bip84: nil), type: Samourai.HD.self)
    }
    
    func updateRealm(hd: Samourai.HD) -> Promise<Samourai.HD> {
        return Promise<Samourai.HD> { seal in
            
            hd.addresses.forEach { (yWallet) in
                guard let wallet = realm.objects(Wallet.self).filter(NSPredicate(format: "address == %@", yWallet.address)).first else { return }
                
                do {
                    try realm.write {
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
            
            hd.addresses.forEach({ (address) in
                
                guard let wallet = realm.objects(Wallet.self).filter(NSPredicate(format: "address == %@", address.address)).first else {
                    return
                }
                
                guard (address.account_index != nil) else {
                    return
                }
                
                func setAccIndex() {
                    do {
                        try realm.write {
                            wallet.accIndex.value = address.account_index
                            realm.add(wallet, update: true)
                        }
                    } catch {}
                }
                
                if let currentAccIndex = wallet.accIndex.value {
                    guard currentAccIndex != address.account_index else {
                        return
                    }
                    setAccIndex()
                }else{
                    setAccIndex()
                }
            })
            
            hd.txs.forEach { (transaction) in
                let wTransaction = WalletTransaction()
                wTransaction.txid = transaction.hash
                wTransaction.value = transaction.result
                wTransaction.time = transaction.time
                
                if let bHeight = transaction.block_height {
                    let confirmations = (hd.info.latest_block.height - bHeight) + 1
                    if confirmations > 2 {
                        wTransaction.conf = 3
                    }else{
                        wTransaction.conf = confirmations
                    }
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
                
                let local = realm.objects(WalletTransaction.self).filter(NSPredicate(format: "txid == %@", transaction.hash)).first
                
                guard !wTransaction.isEqual(local) else {
                    return
                }
                
                if UIApplication.shared.applicationState != .active && !(local != nil) {
                    let center = UNUserNotificationCenter.current()
                    
                    let content = UNMutableNotificationContent()
                    
                    if wTransaction.value > 0 {
                        content.title = "Incoming Transaction - \(wTransaction.wallet!.name)"
                        content.body = "A Transaction with value of \(wTransaction.value.btc())btc has been received."
                    }else {
                        content.title = "Outgoing Transaction - \(wTransaction.wallet!.name)"
                        content.body = "A Transaction with value of \(wTransaction.value.btc())btc has been sent."
                    }
                    
                    UIApplication.shared.applicationIconBadgeNumber += 1
                    
                    content.sound = UNNotificationSound.default()
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest(identifier: wTransaction.txid, content: content, trigger: trigger)
                    center.add(request, withCompletionHandler: { (error) in })
                }
                
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
    
    func remove(wallet: Wallet) {
        do {
            try realm.write {
                let transactions = realm.objects(WalletTransaction.self).filter("wallet == %@", wallet)
                realm.delete(transactions)
                realm.delete(wallet)
            }
        }catch {}
    }
}

// MARK: StreetPrice

extension Sentinel {
    
    func updatePrice() -> Promise<Void> {
        return Promise<Void> { seal in
            
            if !(UserDefaults.standard.string(forKey: "PriceSourceCurrency") != nil) {
                _ = UserDefaults.standard.set("Localbitcoins.com USD", forKey: "PriceSourceCurrency")
            }
            
            guard let providerSetting = UserDefaults.standard.string(forKey: "PriceSourceCurrency") else {
                return
            }
            
            let providerStr = providerSetting.split(separator: " ").first!
            let currencyStr = String(providerSetting.split(separator: " ").last!)
            
            var provider: StreetPrice
            switch providerStr {
            case "WEX":
                provider = .wex(currency: currencyStr)
            case "Bitfinex":
                provider = .bitfinex
            default:
                provider = .localbitcoins
            }
            
            streetPriceAPI.request(target: provider).then { (response) -> Promise<[String: Any]> in
                return self.json(data: response.data)
                }.done { (json) in
                    if providerStr == "Localbitcoins.com" {
                        guard let currencyDic = json[currencyStr] as? [String: Any] else { seal.reject(Errors.noPrice); return }
                        guard let average = currencyDic["avg_12h"] as? String else { seal.reject(Errors.noPrice); return }
                        _ = UserDefaults.standard.set(Double(average), forKey: "Price")
                        seal.fulfill(())
                    }else if providerStr == "WEX" {
                        guard let currencyDic = json["btc_\(currencyStr.lowercased())"] as? [String: Any] else { seal.reject(Errors.noPrice); return }
                        guard let average = currencyDic["avg"] as? Double else { seal.reject(Errors.noPrice); return }
                        _ = UserDefaults.standard.set(average, forKey: "Price")
                        seal.fulfill(())
                    }else{
                        guard let average = json["mid"] as? String else { seal.reject(Errors.noPrice); return }
                        _ = UserDefaults.standard.set(Double(average), forKey: "Price")
                        seal.fulfill(())
                    }
                }.catch { (err) in
                    seal.reject(err)
            }
        }
    }
    
    private func json(data: Data) -> Promise<[String: Any]> {
        return Promise<[String: Any]> { seal in
            do {
                if let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    seal.fulfill(decoded)
                }
            }catch let err {
                seal.reject(err)
            }
        }
    }
}

// MARK: Util

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

// MARK: Import/Export

extension Sentinel {
    
    func exportWallet(password: String) -> Promise<String> {
        return Promise<String> { seal in
            guard numberOfWallets > 0 else {
                seal.reject(Errors.nothingToExport)
                return
            }
            
            var all: [[String: Any]] = []
            _ = realm.objects(Wallet.self).forEach({ (wallet) in
                all.append(wallet.raw)
            })
            do {
                let key: Array<UInt8> = Array(password.sha256().bytes[0..<16])
                let json = try JSONSerialization.data(withJSONObject: all, options: [.prettyPrinted])
                let encrypted = try AES(key: key, blockMode: CBC(iv: key), padding: .pkcs5).encrypt(json.bytes).toBase64()!
                let b64 = try JSONSerialization.data(withJSONObject: ["version": "2", "payload": encrypted], options: [.prettyPrinted])
                let str = String(data: b64, encoding: .utf8)
                seal.fulfill(str!)
            } catch let err {
                seal.reject(err)

            }
        }
    }
    
    func importWallet(input: String, password: String) -> Promise<Void> {
        return Promise<Void> { seal in
            
            let key: Array<UInt8> = Array(password.sha256().bytes[0..<16])
            
            guard let inputData = input.data(using: .utf8), let decodedInput = try? JSONSerialization.jsonObject(with: inputData, options: []) as? [String: String], let version = decodedInput?["version"], version == "2", let payload = decodedInput?["payload"], let decryptedWallets = try? AES(key: key, blockMode: CBC(iv: key), padding: .pkcs5).decrypt(Data(base64Encoded: payload)!.bytes), let wallets = try? JSONSerialization.jsonObject(with: Data(bytes: decryptedWallets), options: []) as? [[String: Any]] else {
                seal.reject(Errors.failedToImport)
                return
            }

            wallets?.forEach { (iWallet) in
                guard let name = iWallet["name"] as? String, let address = iWallet["address"] as? String else {
                    return
                }
                
                do {
                    try realm.write {
                        let newWallet = Wallet()
                        newWallet.name = name
                        newWallet.address = address
                        realm.add(newWallet, update: true)
                    }
                } catch let err {
                    seal.reject(err)
                }
            }
            
            update()
            
            seal.fulfill(())
        }
    }
}

extension Sentinel: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        NSLog("Socket connected")
        socket.write(string: "{\"op\":\"blocks_sub\"}")
        let wallets = realm.objects(Wallet.self)
        wallets.forEach { (wallet) in
            socket.write(string: "{\"op\":\"addr_sub\", \"addr\":\"" + wallet.address + "\"}")
        }
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Socket Disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard text.count > 5 else { return }
        update()
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) { }
}

extension Sentinel {
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi, .cellular:
            socket.disconnect()
            self.update()
        case .none:
            socket.disconnect()
        }
    }
}
