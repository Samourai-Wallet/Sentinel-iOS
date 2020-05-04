//
//  DojoManager.swift
//  Sentinel
//
//  Created by Gigi on 01.05.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import Foundation

protocol DojoManagerDelegate : class {
    func dojoConnProgress(_ progress: Int)
    func dojoConnFinished()
    func dojoConnFailed()
}

class DojoManager : NSObject {
    
    enum DojoState {
        case none
        case pairingValid
        case torInitializing
        case torConnected
        case authenticating
        case paired
    }
    
    public static let shared = DojoManager()
    
    var state = DojoState.none
    
    override init() {
        super.init()
    }
    
    // TODO
    func setupDojo(jsonString: String) -> Bool {
        guard let jsonData = jsonString.data(using: .utf8) else {
            NSLog("Error parsing JSON string")
            return false
        }
        let decoder = JSONDecoder()
        
        do {
            let pairing = try decoder.decode(Pairing.self, from: jsonData)
            NSLog("Pairing details: ")
            NSLog("\(pairing)")
            return true
        } catch {
            // TODO: Completion handler to handle success/error and show in UI
            NSLog("Error decoding JSON data. Invalid Dojo pairing details?")
            NSLog("\(error)")
            return false
        }
    }
}

struct PairingDetails : Codable {
    let type: String
    let version: String
    let apikey: String
    let url: String
    
    func validate() -> Bool {
        guard URL(string: url) != nil else {
            NSLog("URL validation failed")
            return false
        }
        return true
    }
}

struct Pairing : Codable {
    let pairing: PairingDetails
}
