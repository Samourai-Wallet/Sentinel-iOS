//
//  TorManager.swift
//  Sentinel
//
//  Created by Gigi on 17.04.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import Foundation
import Alamofire

protocol TorManagerDelegate : class {
    func torConnProgress(_ progress: Int)
    func torConnFinished()
}

class TorManager : NSObject {

    enum TorState {
        case none
        case started
        case connected
        case stopped
    }

    public static let shared = TorManager()
    public var state = TorState.none
    
    private static let configuration = TorConfig()
    private var torSession : Alamofire.Session?
    private var torController: TorController?
    private var torThread: TorThread?

    private var cookie: Data? {
        if let cookieUrl = TorManager.configuration.dataDirectory?.appendingPathComponent("control_auth_cookie") {
            return try? Data(contentsOf: cookieUrl)
        }
        return nil
    }
    
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
    
    private func constructSession(configuration: URLSessionConfiguration) -> Alamofire.Session {
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

    func startTor(delegate: TorManagerDelegate?) {
        state = .started
        
        torController = TorController(socketHost: "127.0.0.1", port: 39060)
        torThread = TorThread(configuration: TorManager.configuration)
        torThread?.start()
        
        // Use weakDelegate in closures to avoid retain cycles
        weak var weakDelegate = delegate
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            if !(self.torController?.isConnected ?? false) {
                do {
                    try self.torController?.connect()
                } catch {
                    NSLog("\(error)")
                }
            }

            guard let cookie = self.cookie else {
                NSLog("Could not connect to Tor - cookie unreadable!")
                return
            }
            
            self.torController?.authenticate(with: cookie, completion: { success, error in
                if success {
                    NSLog("Success!")
                    
                    var completeObs: Any?
                    completeObs = self.torController?.addObserver(forCircuitEstablished: { established in
                        if established {
                            NSLog("Success! Circuit established")
                            self.state = .connected
                            self.torController?.removeObserver(completeObs)
                            self.torController?.getSessionConfiguration({ (conf: URLSessionConfiguration?) in
                                self.torSession = TorManager.shared.constructSession(configuration: conf!)
                            })
                            weakDelegate?.torConnFinished()
                        }
                    })
                    
                    var progressObserver: Any?
                    progressObserver = self.torController?.addObserver(forStatusEvents: {
                        (type: String, severity: String, action: String, arguments: [String : String]?) -> Bool in

                        if type == "STATUS_CLIENT" && action == "BOOTSTRAP" {
                            let progress = Int(arguments!["PROGRESS"]!)!
                            weakDelegate?.torConnProgress(progress)
                            if progress >= 100 {
                                self.torController?.removeObserver(progressObserver)
                            }
                            return true
                        }

                        return false
                    })
                } else {
                    NSLog("Didn't connect to control port.")
                }
            })
        })
    }
    
    func stopTor() {
        torController?.disconnect()
        torController = nil

        // More cleanup
        torThread?.cancel()
        torThread = nil

        state = .stopped
    }
}
