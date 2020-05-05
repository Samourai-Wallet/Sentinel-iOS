//
//  DojoProvider.swift
//  Sentinel
//
//  Created by Gigi on 05.05.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import Foundation
import Moya

enum Dojo {
    case login(apiKey: String)
}

extension Dojo : TargetType {
    
    var baseURL: URL {
        guard let dojo = DojoManager.shared.dojoParams else {
            NSLog("Dojo not initialized")
            return URL(string: "")! // TODO - throw error
        }
        
        return URL(string: dojo.url)!
    }
    
    var path: String {
        switch self {
        case .login:
            return "auth/login"
        }
    }
        
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case let .login(apiKey):
            return .requestParameters(parameters: ["apikey": apiKey], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
        
}
