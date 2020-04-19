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

    static let shared = TorManager()
    public var state = TorState.none
    private var torSession : Alamofire.Session?
    
    private static let torBaseConf : TorConfiguration = {
        let conf = TorConfiguration()
        conf.cookieAuthentication = true

        #if DEBUG
        let logLocation = "notice stdout"
        #else
        let logLocation = "notice file /dev/null"
        #endif

        conf.arguments = [
            "--allow-missing-torrc",
            "--ignore-missing-torrc",
            "--ClientOnly", "1",
            "--AvoidDiskWrites", "1",
            "--SocksPort", "127.0.0.1:39050",
            "--ControlPort", "127.0.0.1:39060",
            "--Log", logLocation,
            "--ClientUseIPv6", "1"
        ]


        // Store in <appdir>/Library/Caches/tor to persist descriptors etc
        if let dataDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("tor", isDirectory: true) {

            // Create data dir if necessary
            try? FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)

            // Create auth dir if necessary
            let authDir = dataDir.appendingPathComponent("auth", isDirectory: true)
            try? FileManager.default.createDirectory(at: authDir, withIntermediateDirectories: true)

            conf.dataDirectory = dataDir
            conf.arguments += ["--ClientOnionAuthDir", authDir.path]
        }

        return conf
    }()
        
    private var torController: TorController?
    private var torThread: TorThread?

    private var cookie: Data? {
        if let cookieUrl = TorManager.torBaseConf.dataDirectory?.appendingPathComponent("control_auth_cookie") {
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
        torThread = TorThread(configuration: TorManager.torBaseConf)
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
