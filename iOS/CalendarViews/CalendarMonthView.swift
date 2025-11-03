//
//  CalendarMonthView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 03/11/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct CalendarMonthView: View {
    var date: FrenchRepublicanDate
    // true: show 5 columns, false: show 10 columns
    var halfWeek: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(date, format: .republicanDate.day(.monthOnly).year(.long))
                .font(.headline)
                .padding()
            ForEach(0..<(halfWeek ? 6 : 3), id: \.self) { row in
                CalendarMonthRow(date: date, halfWeek: halfWeek, row: row)
            }
        }
    }
}

struct CalendarMonthRow: View {
    var date: FrenchRepublicanDate
    var halfWeek: Bool = false
    var row: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<(halfWeek ? 5 : 10), id: \.self) { col in
                Spacer(minLength: col == 0 ? 0 : 2)
                let date = FrenchRepublicanDate(
                    dayInYear: (self.date.components.month! - 1) * 30 + row * (halfWeek ? 5 : 10) + col + 1,
                    year: self.date.components.year!)
                CalendarMonthItem(date: date, selected: date.components.day == self.date.components.day)
            }
            Spacer(minLength: 0)
        }
    }
}

struct CalendarMonthItem: View {
    var date: FrenchRepublicanDate
    var selected: Bool
    
    var isWeekend: Bool {
        date.isSansculottides || date.components.day! % 10 == 0
    }
    
    var isToday: Bool {
        Calendar.gregorian.isDateInToday(date.date)
    }

    var body: some View {
        Text(date.dayInYear <= (date.isYearSextil ? 366 : 365) ? "\(date.components.day!)" : "")
            .fontWeight(selected ? .semibold : .regular)
            .minimumScaleFactor(0.5)
            .padding(10)
            .foregroundStyle(
                selected && isToday ? .white
                : selected || isToday ? .red
                : isWeekend ? .secondary
                : .primary)
            .aspectRatio(1, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .background(Circle().fill(
                selected && isToday ? Color.red
                : selected ? Color.red.opacity(0.15)
                : Color.clear
            ))
    }
}
