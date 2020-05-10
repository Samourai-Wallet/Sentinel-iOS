//
//  Settings.swift
//  Sentinel
//
//  Created by Gigi on 06.05.20.
//  Copyright © 2020 Samourai. All rights reserved.
//

import Foundation

struct Settings {
    
    static var isTorEnabled : Bool {
        guard let isEnabled = UserDefaults.standard.value(forKey: "isTorEnabled") as? Bool else {
            return false
        }
        return isEnabled
    }
    
    static var isDojoEnabled : Bool {
        guard let isEnabled = UserDefaults.standard.value(forKey: "isDojoEnabled") as? Bool else {
            return false
        }
        return isEnabled
    }
    
    static func enableTor() {
        UserDefaults.standard.set(true, forKey: "isTorEnabled")
    }
    
    static func disableTor() {
        UserDefaults.standard.set(false, forKey: "isTorEnabled")
    }
    
    static func enableDojo() {
        UserDefaults.standard.set(true, forKey: "isDojoEnabled")
    }
    
    static func disableDojo() {
        UserDefaults.standard.set(false, forKey: "isDojoEnabled")
    }
    
}
