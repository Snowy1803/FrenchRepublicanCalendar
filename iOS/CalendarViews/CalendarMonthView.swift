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
    var month: FrenchRepublicanDate
    @Binding var selection: FrenchRepublicanDate
    // true: show 5 columns, false: show 10 columns
    var halfWeek: Bool = true
    // true: show 3/6 rows, false: show less rows for Sansculottides
    var constantHeight: Bool = true
    
    var rowCount: Int {
        if !constantHeight && month.isSansculottides {
            if month.isYearSextil && halfWeek {
                2
            } else {
                1
            }
        } else {
            if halfWeek {
                6
            } else {
                3
            }
        }
    }
    
    var body: some View {
        VStack {
            ForEach(0..<rowCount, id: \.self) { row in
                CalendarMonthRow(month: month, row: row, selection: $selection, halfWeek: halfWeek)
            }
        }
    }
}

struct CalendarMonthRow: View {
    var month: FrenchRepublicanDate
    var row: Int
    @Binding var selection: FrenchRepublicanDate
    var halfWeek: Bool = false
    
    var colCount: Int {
        if halfWeek {
            5
        } else {
            10
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<colCount, id: \.self) { col in
                Spacer(minLength: 0)
                let date = FrenchRepublicanDate(
                    dayInYear: (month.components.month! - 1) * 30 + row * colCount + col + 1,
                    year: month.components.year!)
                CalendarMonthItem(date: date, selection: $selection)
            }
            Spacer(minLength: 0)
        }
    }
}

struct CalendarMonthItem: View {
    var date: FrenchRepublicanDate
    @Binding var selection: FrenchRepublicanDate
    
    var isSelected: Bool {
        isValid && Calendar.gregorian.isDate(date.date, inSameDayAs: selection.date)
    }
    
    var isWeekend: Bool {
        date.isSansculottides || date.components.day! % 10 == 0
    }
    
    var isToday: Bool {
        Calendar.gregorian.isDateInToday(date.date)
    }
    
    var isValid: Bool {
        date.dayInYear <= (date.isYearSextil ? 366 : 365)
    }

    var body: some View {
        Button {
            selection = date
        } label: {
            Text(isValid ? "\(date.components.day!)" : "0")
                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(
                    !isValid ? .clear
                    : isSelected && isToday ? .white
                    : isSelected || isToday ? .accentColor
                    : isWeekend ? .secondary
                    : .primary)
        }
        .buttonStyle(CalendarDayButtonStyle(isSelected: isSelected, isToday: isToday))
        .disabled(!isValid)
        .accessibilityHidden(!isValid)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel(isValid ? Text("\(isToday ? "Aujourd'hui, " : "")\(date, format: .republicanDate.day(.preferred).year(.long))") : Text(""))
    }
}

struct CalendarDayButtonStyle: ButtonStyle {
    var isSelected: Bool
    var isToday: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .minimumScaleFactor(0.5)
            .padding(10)
            .aspectRatio(1, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .background(Circle().fill(
                Color.accentColor.opacity(
                    isSelected && isToday ? 1
                    : isSelected ? 0.12
                    : configuration.isPressed ? 0.06
                    : 0
                )
            ))
            .contentShape(Circle())
    }
}
