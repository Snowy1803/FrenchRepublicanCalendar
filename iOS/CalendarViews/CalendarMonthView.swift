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

struct CalendarMonthView<Item: View>: View {
    var month: FrenchRepublicanDate
    // true: show 5 columns, false: show 10 columns
    var halfWeek: Bool = true
    // true: show 3/6 rows, false: show less rows for Sansculottides
    var constantHeight: Bool = true
    var scale: CGFloat = 1
    @ViewBuilder var itemProvider: (FrenchRepublicanDate?) -> Item
    
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
        VStack(spacing: 8 * scale) {
            ForEach(0..<rowCount, id: \.self) { row in
                CalendarMonthRow(month: month, row: row, halfWeek: halfWeek, itemProvider: itemProvider)
            }
        }
    }
}

extension CalendarMonthView where Item == CalendarMonthItem {
    init(month: FrenchRepublicanDate, selection: Binding<FrenchRepublicanDate>, halfWeek: Bool = true, constantHeight: Bool = true) {
        let today = FrenchRepublicanDate(date: .now)
        let isCurrentMonth = today.monthIndex == month.monthIndex
        let todayDay = isCurrentMonth ? today.components.day : nil
        self.init(month: month, halfWeek: halfWeek, constantHeight: constantHeight) { date in
            let isToday = date.flatMap { $0.components.day == todayDay } ?? false
            CalendarMonthItem(date: date, selection: selection, isToday: isToday)
        }
    }
}

struct CalendarMonthRow<Item: View>: View {
    var month: FrenchRepublicanDate
    var row: Int
    var halfWeek: Bool = false
    @ViewBuilder var itemProvider: (FrenchRepublicanDate?) -> Item
    
    var colCount: Int {
        if halfWeek {
            5
        } else {
            10
        }
    }

    var body: some View {
        let daysInMonth = month.isSansculottides ? (month.isYearSextil ? 6 : 5) : 30
        HStack(spacing: 0) {
            ForEach(0..<colCount, id: \.self) { col in
                Spacer(minLength: 0)
                let day = row * colCount + col + 1
                let date = day <= daysInMonth ? FrenchRepublicanDate(day: day, month: month.components.month!, year: month.year) : nil
                itemProvider(date)
            }
            Spacer(minLength: 0)
        }
    }
}

struct CalendarMonthItem: View {
    var date: FrenchRepublicanDate?
    @Binding var selection: FrenchRepublicanDate
    var hardSelection = false
    var isToday: Bool = false
    
    var isSelected: Bool {
        if let date {
            isValid && date.inSameDay(as: selection)
        } else {
            false
        }
    }
    
    var isWeekend: Bool {
        if let date {
            date.isSansculottides || date.components.day! % 10 == 0
        } else {
            false
        }
    }
    
    var isValid: Bool {
        date != nil
    }

    var body: some View {
        Button {
            if let date {
                selection = date
            }
        } label: {
            Text(isValid ? "\(date!.components.day!)" : "0")
                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(
                    !isValid ? .clear
                    : isSelected && isToday ? .white
                    : isSelected && hardSelection ? .fullBackground
                    : isSelected || isToday ? .accentColor
                    : isWeekend ? .secondary
                    : .primary)
        }
        .buttonStyle(CalendarDayButtonStyle(isSelected: isSelected, isToday: isToday, hardSelection: hardSelection))
        .disabled(!isValid)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel(isValid ? Text("\(isToday ? "Aujourd'hui, " : "")\(date!, format: .republicanDate.day(.preferred).year(.long))") : Text(""))
        .accessibilityHidden(!isValid) // this doesnt work
    }
}

struct CalendarDayButtonStyle: ButtonStyle {
    var isSelected: Bool
    var isToday: Bool
    var hardSelection: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(10)
            .aspectRatio(1, contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Circle().fill(
                hardSelection && !isToday && isSelected ? Color.fullForeground
                : Color.accentColor.opacity(
                    isSelected && isToday ? 1
                    : isSelected ? 0.12
                    : configuration.isPressed ? 0.06
                    : 0
                )
            ))
            .contentShape(Circle())
    }
}
