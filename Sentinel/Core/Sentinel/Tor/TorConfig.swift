//
//  TorConfig.swift
//  Sentinel
//
//  Created by Gigi on 19.04.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import Foundation

class TorConfig : TorConfiguration {
    
    // Tor needs a while to start so cookie doesn't exist right away
    var authCookie: Data? {
        if let cookieUrl = self.dataDirectory?.appendingPathComponent("control_auth_cookie") {
            return try? Data(contentsOf: cookieUrl)
        }
        return nil
    }
    
    override init() {
        super.init()
        self.cookieAuthentication = true

        #if DEBUG
        let logLocation = "notice stdout"
        #else
        let logLocation = "notice file /dev/null"
        #endif

        self.arguments = [
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

            self.dataDirectory = dataDir
            self.arguments += ["--ClientOnionAuthDir", authDir.path]
        }
    }
    
}
