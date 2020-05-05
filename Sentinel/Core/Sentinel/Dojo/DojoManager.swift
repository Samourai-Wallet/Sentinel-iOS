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
    func dojoConnProgress(_ progress: Int, localizedMessage: String)
    func dojoConnFinished()
    func dojoConnFailed(_ error: Error, message: String)
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
            
            let params = DojoParams(with: pairing.pairing)
            if params.pairingDetails.isValid() {
                self.dojoParams = params
                self.state = .pairingValid
                return true
            } else {
                NSLog("Invalid pairing details (validation failed)")
                return false
            }
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
    
    func pairWithDojo(delegate: DojoManagerDelegate) {
        guard let apiKey = DojoManager.shared.getApiKey() else {
            NSLog("Dojo API Key not set.")
            return
        }
        
        delegate.dojoConnProgress(25, localizedMessage: "Connecting to Dojo Node...") // TODO: i18n
        
        let dojoAPI = MoyaProvider<Dojo>(session: TorManager.shared.sessionHandler.session())
        dojoAPI.request(.login(apiKey: apiKey)) { result in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                let statusCode = moyaResponse.statusCode

                delegate.dojoConnProgress(95, localizedMessage: "Authentication successful") // TODO: i18n
                
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
                        self.state = .paired
                        
                        delegate.dojoConnProgress(100, localizedMessage: "Successfully connected to Dojo") // TODO: i18n
                        delegate.dojoConnFinished()
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
        // We have to store the access tokens in a separate keychain user account ("samouraiDojo")
        // because the code that checks if a PIN is set or not simply checks if *anything* is
        // stored in the regular keychain account (called "account").
        //
        // See RootNavigationController viewDidLoad() and checkForPin()
        try Locksmith.updateData(data: ["access_token" : accessToken], forUserAccount: "samouraiDojo")
        try Locksmith.updateData(data: ["refresh_token" : refreshToken], forUserAccount: "samouraiDojo")
        NSLog("Access tokens stored in keychain")
    } catch {
        NSLog("Error saving access tokens")
        NSLog("\(error)") // TODO
    }
}

func wipeAccessTokens() {
    do {
        try Locksmith.deleteDataForUserAccount(userAccount: "samouraiDojo")
    } catch {
        NSLog("Error wiping access tokens from keychain")
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
    
    func isValid() -> Bool {
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
