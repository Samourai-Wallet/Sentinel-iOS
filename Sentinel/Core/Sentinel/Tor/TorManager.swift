//
//  TorManager.swift
//  Sentinel
//
//  Created by Gigi on 17.04.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import Foundation

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
    
    var state = TorState.none
    var sessionHandler = SessionHandler()
    
    private static let configuration = TorConfig()
    private var torController: TorController?
    private var torThread: TorThread?

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

            guard let cookie = TorManager.configuration.authCookie else {
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
                                self.sessionHandler.torSessionEstablished(conf!)
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
    
    func torReconnect(_ callback: ((_ success: Bool) -> Void)? = nil) {
        torController?.resetConnection(callback)
    }
    
    func closeAllCircuits(_ callback: @escaping ((_ success: Bool) -> Void)) {
        self.getCircuits { circuits in
            self.closeCircuits(circuits, callback)
        }
    }
    
    func closeCircuits(_ circuits: [TorCircuit], _ callback: @escaping ((_ success: Bool) -> Void)) {
        torController?.close(circuits, completion: callback)
    }
    
    func getCircuits(_ callback: @escaping ((_ circuits: [TorCircuit]) -> Void)) {
        torController?.getCircuits(callback)
    }
}
