//
//  SaveableFrenchRepublicanDateOptions.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 12/04/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import FrenchRepublicanCalendarCore
import WatchConnectivity
#if os(iOS)
import WidgetKit
#endif

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

extension FrenchRepublicanDateOptions: @retroactive SaveableFrenchRepublicanDateOptions {
    public static var current: FrenchRepublicanDateOptions {
        get {
            FrenchRepublicanDateOptions(
                romanYear: UserDefaults.shared.bool(forKey: "frdo-roman"),
                variant: Variant(rawValue: UserDefaults.shared.integer(forKey: "frdo-variant")) ?? .original
            )
        }
        set { // only called on iOS
            UserDefaults.shared.set(newValue.romanYear, forKey: "frdo-roman")
            UserDefaults.shared.set(newValue.variant.rawValue, forKey: "frdo-variant")
            WCSession.default.transferUserInfo(["frdo-roman": newValue.romanYear, "frdo-variant": newValue.variant.rawValue])
            #if os(iOS)
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
            #endif
        }
    }
}
