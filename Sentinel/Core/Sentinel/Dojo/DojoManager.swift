//
//  DojoManager.swift
//  Sentinel
//
//  Created by Gigi on 01.05.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import Foundation
import Locksmith
import Moya

protocol DojoManagerDelegate : class {
    func dojoConnProgress(_ progress: Int)
    func dojoConnFinished()
    func dojoConnFailed()
}

class DojoParams : NSObject {
    
    let pairingDetails : PairingDetails
    var apiKey: String {
        return pairingDetails.apikey
    }
    var url: String {
        return pairingDetails.url
    }
    
    init(with details: PairingDetails) {
        self.pairingDetails = details
    }
    
}

class DojoManager : NSObject {
    
    enum DojoState {
        case none
        case pairingValid
        case authenticating
        case paired
    }
    
    public static let shared = DojoManager()
    
    var state = DojoState.none
    var dojoParams : DojoParams?
    
    override init() {
        super.init()
    }
    
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
            self.dojoParams = DojoParams(with: pairing.pairing)
            return true
        } catch {
            // TODO: Completion handler to handle success/error and show in UI
            NSLog("Error decoding JSON data. Invalid Dojo pairing details?")
            NSLog("\(error)")
            return false
        }
    }
    
    func getApiKey() -> String? {
        guard let pairedDojo = self.dojoParams else {
            return nil
        }
        return pairedDojo.pairingDetails.apikey
    }
    
    func getDojoUrl() -> URL? {
        guard let pairedDojo = self.dojoParams else {
            return nil
        }
        return URL(string: pairedDojo.pairingDetails.url)
    }
    
    func pairWithDojo() {
        guard let apiKey = DojoManager.shared.getApiKey() else {
            NSLog("Dojo API Key not set.")
            return
        }
        
        let dojoAPI = MoyaProvider<Dojo>(session: TorManager.shared.sessionHandler.session())
        dojoAPI.request(.login(apiKey: apiKey)) { result in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                let statusCode = moyaResponse.statusCode

                // TODO
                NSLog("HTTP \(statusCode)")
                NSLog("\(data)")
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let authResponse = try decoder.decode(DojoAuthResponse.self, from: data)
                        let accessToken = authResponse.authorizations.accessToken
                        let refreshToken = authResponse.authorizations.refreshToken
                        saveAccessTokens(accessToken: accessToken, refreshToken: refreshToken)
                    } catch {
                        // TODO: Handle success/error and show in UI
                        NSLog("Error decoding JSON data returned from Dojo authentication process")
                        NSLog("\(error)")
                    }
                } catch {
                    // TODO
                    NSLog("Error \(error)")
                }
            case let .failure(error):
                // TODO
                NSLog("ERROR! \(error)")
            }
        }
    }
}

func saveAccessTokens(accessToken: String, refreshToken: String) {
    do {
        try Locksmith.saveData(data: ["access_token" : accessToken], forUserAccount: "account")
        try Locksmith.saveData(data: ["refresh_token" : refreshToken], forUserAccount: "account")
        NSLog("Access tokens stored in keychain")
    } catch {
        NSLog("Error saving access tokens")
        NSLog("\(error)") // TODO
    }
}

// MARK: Pairing

struct Pairing : Codable {
    let pairing: PairingDetails
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

struct DojoAuthResponse : Codable {
    let authorizations: AuthorizationTokens
}

struct AuthorizationTokens : Codable {
    let accessToken: String
    let refreshToken: String
    
    private enum CodingKeys : String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}
