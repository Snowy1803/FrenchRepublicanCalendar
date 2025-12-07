//
//  ScrollableCalendarView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 02/12/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
@_spi(Advanced) import SwiftUIIntrospect

extension FrenchRepublicanDate {
    var monthIndex: Int {
        (self.year - 1) * 13 + self.components.month! - 1
    }
}

struct MonthCollection: RandomAccessCollection {
    var startIndex: Int {
        0
    }
    var endIndex: Int {
        let max = FrenchRepublicanDate(date: FrenchRepublicanDate.maxSafeDate)
        return max.monthIndex
    }
    
    typealias Element = FrenchRepublicanDate
    typealias Index = Int
//    typealias SubSequence = Array
    typealias Indices = Range<Int>
    
    subscript(position: Int) -> FrenchRepublicanDate {
        get {
            let year = position / 13 + 1
            let month = position % 13 + 1
            return FrenchRepublicanDate(day: 1, month: month, year: year)
        }
    }
}
