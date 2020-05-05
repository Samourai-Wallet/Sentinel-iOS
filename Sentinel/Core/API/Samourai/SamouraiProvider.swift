//
//  APIProvider.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 31.05.18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import Foundation
import Moya

enum Samourai {
    case multiaddr(active: [String]?, new: [String]?, bip49: [String]?, bip84: [String]?)
    case unspent(active: [String]?, new: [String]?, bip49: [String]?, bip84: [String]?)
    case xpub(xpub: String)
    case addxpub(xpub: String, type: String, segwit: String?)
    case tx(txid: String)
    case pushtx(tx: String)
    case header(hash: String)
    case fees
}

extension Samourai: TargetType {
    
    var baseURL: URL {
        switch Sentinel.state {
        case .dojoTor:
            return DojoManager.shared.getDojoUrl()!
        case .samouraiTor:
            return URL(string: "http://d2oagweysnavqgcfsfawqwql2rwxend7xxpriq676lzsmtfwbt75qbqd.onion/v2/")!
        case .samouraiClear:
            return URL(string: "https://api.samouraiwallet.com/v2/")!
        }
    }
    
    var path: String {
        switch self {
        case .multiaddr:
            return "multiaddr"
        case .unspent:
            return "unspent"
        case .xpub(let xpub):
            return "xpub/\(xpub)"
        case .addxpub:
            return "xpub/"
        case .tx(let txid):
            return "tx/\(txid)"
        case .pushtx:
            return "pushtx"
        case .header(let hash):
            return "header/\(hash)"
        case .fees:
            return "fees"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addxpub:
            return .post
        case .pushtx:
            return .post
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case let .multiaddr(active, new, bip49, bip84), let .unspent(active, new, bip49, bip84):
            return .requestParameters(parameters: parameters(active: active, new: new, bip49: bip49, bip84: bip84), encoding: URLEncoding.default)
        case let .addxpub(xpub, type, segwit):
            return .requestParameters(parameters: parameters(xpub: xpub, type: type, segwit: segwit), encoding: URLEncoding.default)
        case let .pushtx(tx):
            return .requestParameters(parameters: ["tx": tx], encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

extension Samourai {
    private func parameters(active: [String]?, new: [String]?, bip49: [String]?, bip84: [String]?) -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        if let active = active {
            parameters["active"] = active.joined(separator: "|")
        }
        
        if let new = new {
            parameters["new"] = new.joined(separator: "|")
        }
        
        if let bip49 = bip49 {
            parameters["bip49"] = bip49.joined(separator: "|")
        }
        
        if let bip84 = bip84 {
            parameters["bip84"] = bip84.joined(separator: "|")
        }
        
        return parameters
    }
    
    private func parameters(xpub: String, type: String, segwit: String?) -> [String: Any] {
        var parameters: [String: Any] = [:]
        parameters["xpub"] = xpub
        parameters["type"] = type
        if let segwit = segwit {
            parameters["segwit"] = segwit
        }
        return parameters
    }
}
