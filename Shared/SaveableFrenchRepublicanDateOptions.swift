//
//  SaveableFrenchRepublicanDateOptions.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 12/04/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import Foundation
import FrenchRepublicanCalendarCore
import WatchConnectivity

extension UserDefaults {
    /// this is only used for variants, use standard for favorites
    static let shared: UserDefaults = {
        #if os(watchOS)
        return standard
        #else
        return UserDefaults(suiteName: "group.fr.orbisec.RepublicanCalendar")!
        #endif
    }()
}

extension FrenchRepublicanDateOptions: SaveableFrenchRepublicanDateOptions {
    public static var current: FrenchRepublicanDateOptions {
        get {
            FrenchRepublicanDateOptions(
                romanYear: UserDefaults.shared.bool(forKey: "frdo-roman"),
                variant: Variant(rawValue: UserDefaults.shared.integer(forKey: "frdo-variant")) ?? .original
            )
        }
        set {
            UserDefaults.shared.set(newValue.romanYear, forKey: "frdo-roman")
            UserDefaults.shared.set(newValue.variant.rawValue, forKey: "frdo-variant")
            WCSession.default.transferUserInfo(["frdo-roman": newValue.romanYear, "frdo-variant": newValue.variant.rawValue])
        }
    }
}
