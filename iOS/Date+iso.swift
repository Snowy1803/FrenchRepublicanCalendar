//
//  RepublicanDatePicker.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

extension Date {
    var iso: String {
        let cmps = Calendar.gregorian.dateComponents([.year, .month, .day], from: self)
        return "\(cmps.year!)-\(cmps.month!)-\(cmps.day!)"
    }
}
