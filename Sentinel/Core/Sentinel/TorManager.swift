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
    func torConnDifficulties()
}

class TorManager : NSObject {

    enum TorState {
        case none
        case started
        case connected
        case stopped
    }

    static let shared = TorManager()
    
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

    func startTor(delegate: TorManagerDelegate?) {
        torController = TorController(socketHost: "127.0.0.1", port: 39060)
        torThread = TorThread(configuration: TorManager.torBaseConf)
        torThread?.start()
        
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
                    
                    self.torController?.addObserver(forCircuitEstablished: { established in
                        if established {
                            NSLog("Success! Circuit established")
                            self.torController?.getSessionConfiguration({ (conf: URLSessionConfiguration?) in
                                NSLog("Getting session configuration...")
                                let session = URLSession(configuration: conf!)
                                let url = URL(string: "https://check.torproject.org/")!
                                let task = session.dataTask(with: url) { data, response, error in
                                    if let error = error {
                                        NSLog("Error!")
                                        NSLog(error.localizedDescription)
                                        return
                                    }
                                    guard let httpResponse = response as? HTTPURLResponse,
                                        (200...299).contains(httpResponse.statusCode) else {
                                        NSLog("Success! 200-something.")
                                        return
                                    }
                                    if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                                        let data = data,
                                        let string = String(data: data, encoding: .utf8) {
                                        DispatchQueue.main.async {
                                            NSLog(string)
                                        }
                                    }
                                }
                                task.resume()
                            })
                        }
                    })
                } else {
                    NSLog("Didn't connect to control port.")
                }
            })
        })
    }
}
