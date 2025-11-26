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
        return UserDefaults(suiteName: "group.fr.orbisec.RepublicanCalendar")!
    }()
}

extension FrenchRepublicanDateOptions: @retroactive SaveableFrenchRepublicanDateOptions {
    private static func saveableTimeZoneIdentifier(_ tz: TimeZone?) -> String {
        guard let tz else { return "" }
        return if tz == TimeZone.parisMeridian {
            "FRC/Paris"
        } else {
            tz.identifier
        }
    }
    
    private static func parseTimeZoneIdentifier(_ id: String?) -> TimeZone? {
        guard let id, id != "" else { return nil }
        if id == "FRC/Paris" {
            return .parisMeridian
        } else {
            return TimeZone(identifier: id)
        }
    }
    
    public static var current: FrenchRepublicanDateOptions {
        get {
            FrenchRepublicanDateOptions(
                romanYear: UserDefaults.shared.bool(forKey: "frdo-roman"),
                variant: Variant(rawValue: UserDefaults.shared.integer(forKey: "frdo-variant")) ?? .original,
                timeZone: parseTimeZoneIdentifier(UserDefaults.shared.string(forKey: "frdo-timezone"))
            )
        }
        set { // only called on iOS
            UserDefaults.shared.set(newValue.romanYear, forKey: "frdo-roman")
            UserDefaults.shared.set(newValue.variant.rawValue, forKey: "frdo-variant")
            UserDefaults.shared.set(saveableTimeZoneIdentifier(newValue.timeZone), forKey: "frdo-timezone")
            WCSession.default.transferUserInfo([
                "frdo-roman": newValue.romanYear,
                "frdo-variant": newValue.variant.rawValue,
                "frdo-timezone": saveableTimeZoneIdentifier(newValue.timeZone)
            ])
            #if os(iOS)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
}
