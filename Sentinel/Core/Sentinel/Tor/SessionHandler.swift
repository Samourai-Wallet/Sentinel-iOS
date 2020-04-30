//
//  TorManager+Session.swift
//  Sentinel
//
//  Created by Gigi on 19.04.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import Foundation
import Alamofire

class SessionHandler {
    
    private var torSession : Alamofire.Session?
    
    func session() -> Alamofire.Session {
        switch (TorManager.shared.state) {
        case .connected:
            guard self.torSession != nil else {
                NSLog("Tor connected but no valid session returned. Using default.")
                return Alamofire.Session.default
            }
            return self.torSession!
        default:
            return Alamofire.Session.default
        }
    }
    
    func torSessionEstablished(_ configuration: URLSessionConfiguration) {
        self.torSession = constructSession(configuration)
    }
    
    private func constructSession(_ configuration: URLSessionConfiguration) -> Alamofire.Session {
        if let session = self.torSession {
            return session
        }
        
        let rootQueue = DispatchQueue(label: "com.samouraiwallet.torQueue")
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.underlyingQueue = rootQueue
        let delegate = SessionDelegate()
        let urlSession = URLSession(configuration: configuration,
                                    delegate: delegate,
                                    delegateQueue: queue)
        return Session(session: urlSession, delegate: delegate, rootQueue: rootQueue)
    }
    
}
