//
//  FavoritesPool.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 21/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WatchConnectivity
import Combine
import FrenchRepublicanCalendarCore

class FavoritesPool: NSObject, ObservableObject, WCSessionDelegate {
    @Published var favorites: [String]
    var needsTransfer: Bool
    
    override init() {
        let defaults = UserDefaults.standard.array(forKey: "favorites")
        needsTransfer = defaults == nil
        favorites = defaults as? [String] ?? [String]()
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sync() {
        UserDefaults.standard.set(favorites, forKey: "favorites")
        if WCSession.isSupported() {
            print("syncing")
            WCSession.default.transferUserInfo(["favorites": favorites])
        }
    }
    
    // MARK: WatchConnectivity session delegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated && needsTransfer {
            session.transferUserInfo(["gimme": true])
            needsTransfer = false
        }
    }
    
    #if os(iOS)
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    #endif
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        #if DEBUG
        print("Received keys: \(userInfo.keys)")
        #endif
        var updateComplication = false
        for (key, value) in userInfo {
            switch key {
            case "favorites":
                if let favorites = value as? [String] {
                    DispatchQueue.main.async {
                        self.favorites = favorites
                        print("synced")
                    }
                } else {
                    print("received invalid favorites data")
                }
            case "gimme":
                session.transferUserInfo(["favorites": favorites])
            case "frdo-roman", "frdo-variant", "frdo-timezone":
                UserDefaults.shared.set(value, forKey: key)
                updateComplication = true
            default:
                print("unknown key \(key) in transfer")
            }
        }
        if updateComplication {
            DispatchQueue.main.async {
                FrenchRepublicanDateOptions.reloadTimelines()
            }
        }
    }
}

/// ObservableObject for significant time changes (iOS) and settings changes
class Midnight: ObservableObject {
    static let shared = Midnight()
}


// UI-Specific Int because using Int as tags will use their value instead of the tag

extension Int {
    var wrapped: IntWrapper {
        get {
            IntWrapper(value: self)
        }
        set {
            self = newValue.value
        }
    }
}

struct IntWrapper: Hashable {
    var value: Int
}
