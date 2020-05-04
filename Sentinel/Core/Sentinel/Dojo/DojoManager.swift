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

struct Pairing : Codable {
    var type: String?
    var version: String?
    var apikey: String?
    var url: String?
    
    func validate() -> Bool {
        guard type != nil else {
            NSLog("No pairing type provided")
            return false
        }
        guard version != nil else {
            NSLog("No Dojo version provided")
            return false
        }
        guard apikey != nil else {
            NSLog("No API key provided")
            return false
        }
        guard let urlStr = self.url else {
            NSLog("No URL provided")
            return false
        }
        guard URL(string: urlStr) != nil else {
            NSLog("URL validation failed")
            return false
        }
        return true
    }
}
