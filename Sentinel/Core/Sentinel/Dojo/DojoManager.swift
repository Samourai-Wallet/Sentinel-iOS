//
//  Dojo.swift
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

class DojoManager {
    
    enum DojoState {
        case none
        case pairingValid
        case torInitializing
        case torConnected
        case authenticating
        case paired
    }
    
    // TODO
}

struct Pairing : Codable {
    var type: String?
    var version: String?
    var apiKey: String?
    var urlString: String?
    
    func validate() -> Bool {
        guard apiKey != nil else {
            NSLog("No API key provided")
            return false
        }
        guard let urlStr = self.urlString else {
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
