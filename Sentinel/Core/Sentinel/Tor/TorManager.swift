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
    func torConnFinished() // TODO: Rename
    func torSessionEstablished()
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
    
    override init() {
        super.init()
        torController = TorController(socketHost: "127.0.0.1", port: 39060)
        torThread = TorThread(configuration: TorManager.configuration)
    }
    
    func isEnabled() -> Bool {
        switch (TorManager.shared.state) {
        case .stopped, .none:
            return false
        case .started, .connected:
            return true
        }
    }

    func startTor(delegate: TorManagerDelegate?) {
        if state == .none {
            torThread?.start()
        }
        state = .started
        
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
                            weakDelegate?.torConnFinished()
                            self.torController?.getSessionConfiguration({ (conf: URLSessionConfiguration?) in
                                if let configuration = conf {
                                    self.sessionHandler.torSessionEstablished(configuration)
                                    weakDelegate?.torSessionEstablished()
                                    self.state = .connected
                                }
                            })
                            self.torController?.removeObserver(completeObs)
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
    
    func killTor() {
        NSLog("Disconnecting Tor controller...")
        torController?.disconnect()
        torController = nil

        // More cleanup
        NSLog("Cancelling Tor thread...")
        torThread?.cancel()
        torThread = nil
        
        state = .stopped
    }
    
    func stopTor() {
        state = .stopped
        
        // NOTE: It seems that there is no clean way to stop the Tor process
        // The iOS OnionBrowser only implements an experimental shutdown
        // which doesn't seem to work properly. Tor thread is never stopped.
        // See https://github.com/iCepa/Tor.framework/tree/v402.7.1/Tor
        //
        // killTor()
    }
    
    func torReconnect(_ callback: ((_ success: Bool) -> Void)? = nil) {
        // Sends "SIGNAL RELOAD" and "SIGNAL NEWNYM" to the Tor thread.
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
