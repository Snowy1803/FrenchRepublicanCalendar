//
//  FrenchRepublicanDateOptions.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 13/03/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import Foundation

struct FrenchRepublicanDateOptions {
    
    static let `default` = FrenchRepublicanDateOptions(romanYear: false, variant: .original)
    static var current: FrenchRepublicanDateOptions {
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
    
    var romanYear: Bool
    var variant: Variant
    
    enum Variant: Int {
        case original
    }
}
