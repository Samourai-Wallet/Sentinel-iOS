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
    func dojoConnFailed(message: String)
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
    
    func getPairingDetails(jsonString: String, delegate: DojoManagerDelegate) -> DojoParams? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            failWithMessage("Error parsing JSON string", delegate)
            return nil
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
                savePairingDetails(pairingDetails: jsonString)
                return params
            } else {
                failWithMessage("Invalid pairing details", delegate)
                return nil
            }
        } catch {
            failWithMessage("Invalid pairing details", delegate, error)
            return nil
        }
    }
    
    func getDojoUrl() -> URL? {
        guard let pairedDojo = self.dojoParams else {
            return nil
        }
        return URL(string: pairedDojo.pairingDetails.url)
    }
    
    func pairWithDojo(parameters: DojoParams, delegate: DojoManagerDelegate) {
        self.state = .authenticating
        delegate.dojoConnProgress(25, localizedMessage: "Connecting to Dojo...") // TODO: i18n
        
        let dojoAPI = MoyaProvider<Dojo>(session: TorManager.shared.sessionHandler.session())
        dojoAPI.request(.login(apiKey: parameters.apiKey)) { result in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                delegate.dojoConnProgress(90, localizedMessage: "Connection established") // TODO: i18n
                
                let decoder = JSONDecoder()
                
                do {
                    let authResponse = try decoder.decode(DojoAuthResponse.self, from: data)
                    let accessToken = authResponse.authorizations.accessToken
                    let refreshToken = authResponse.authorizations.refreshToken
                    delegate.dojoConnProgress(95, localizedMessage: "Authenticated") // TODO: i18n
                    
                    saveAccessTokens(accessToken: accessToken, refreshToken: refreshToken)
                    self.state = .paired
                    
                    delegate.dojoConnProgress(100, localizedMessage: "Successfully connected to Dojo") // TODO: i18n
                    delegate.dojoConnFinished()
                } catch {
                    failWithMessage("Authentication with Dojo failed", delegate, error)
                }
            case let .failure(error):
                failWithMessage("Failed to connect to Dojo", delegate, error)
            }
        }
    }
    
    func disableDojo() {
        state = .none
        wipePairingDetailsAndAccessTokens()
    }
}

private func failWithMessage(_ message: String, _ delegate: DojoManagerDelegate) {
    failWithMessage(message, delegate, nil)
}

private func failWithMessage(_ message: String, _ delegate: DojoManagerDelegate, _ error: Error?) {
    NSLog("\(message)")
    if let e = error {
        NSLog("\(e)")
    }
    
    DojoManager.shared.state = .none
    delegate.dojoConnFailed(message: message)
}

// MARK: Storage

func savePairingDetails(pairingDetails: String) {
    do {
        try Locksmith.updateData(data: ["pairing_details" : pairingDetails], forUserAccount: "samouraiDojo")
    } catch {
        NSLog("Error saving pairing details")
        NSLog("\(error)") // TODO
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

func wipePairingDetailsAndAccessTokens() {
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
