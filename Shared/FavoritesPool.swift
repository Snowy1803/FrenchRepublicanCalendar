//
//  FavoritesPool.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 21/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import Foundation
import WatchConnectivity
import Combine
import FrenchRepublicanCalendarCore

class FavoritesPool: NSObject, ObservableObject, WCSessionDelegate {
    @Published var favorites: [String]
    
    private var sub: AnyCancellable?
    
    override init() {
        let defaults = UserDefaults.standard.array(forKey: "favorites") as? [String]
        favorites = defaults ?? [String]()
        super.init()
        sub = $favorites.sink { fav in
            UserDefaults.standard.set(fav, forKey: "favorites")
        }
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            if defaults == nil {
                session.transferUserInfo(["gimme": true])
            }
        }
    }
    
    func sync() {
        if WCSession.isSupported() {
            print("syncing")
            WCSession.default.transferUserInfo(["favorites": favorites])
        }
    }
    
    // MARK: WatchConnectivity session delegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    #if os(iOS)
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    #endif
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        if let favorites = userInfo["favorites"] as? [String] {
            DispatchQueue.main.async {
                self.favorites = favorites
                print("synced")
            }
        } else if (userInfo["gimme"] as? Bool) == true {
            session.transferUserInfo(["favorites": favorites])
        } else {
            print("sync data not found")
        }
    }
}

extension FrenchRepublicanDateOptions: SaveableFrenchRepublicanDateOptions {
    public static var current: FrenchRepublicanDateOptions {
        get {
            FrenchRepublicanDateOptions(
                romanYear: UserDefaults.standard.bool(forKey: "frdo-roman"),
                variant: Variant(rawValue: UserDefaults.standard.integer(forKey: "frdo-variant")) ?? .original
            )
        }
        set {
            UserDefaults.standard.set(newValue.romanYear, forKey: "frdo-roman")
            UserDefaults.standard.set(newValue.variant.rawValue, forKey: "frdo-variant")
        }
    }
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
