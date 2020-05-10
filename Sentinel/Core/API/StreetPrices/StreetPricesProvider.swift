//
//  StreetPricesProvider.swift
//  Sentinel
//
//  Created by Farzad Nazifi on 6/5/18.
//  Copyright © 2018 Samourai. All rights reserved.
//

import Moya

enum StreetPrice {
    case localbitcoins
    case wex(currency: String)
    case bitfinex
}

extension StreetPrice: TargetType {
    
    var baseURL: URL {
        switch self {
        case .localbitcoins:
            return URL(string: "https://localbitcoins.com/bitcoinaverage/ticker-all-currencies/")!
        case .wex(let currency):
            return URL(string: "https://wex.nz/api/3/ticker/btc_\(currency.lowercased())")!
        case .bitfinex:
            return URL(string: "https://api.bitfinex.com/v1/pubticker/btcusd")!
        }
    }
    
    var path: String {
        return ""
    }
    
    var method: Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    struct Bitfinex: Codable {
        let mid: String
        let timestamp: String
    }
}
