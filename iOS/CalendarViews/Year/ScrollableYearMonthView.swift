//
//  ScrollableYearMonthView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 07/12/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct ScrollableYearMonthView: View {
    var month: FrenchRepublicanDate
    var selectMonth: (FrenchRepublicanDate) -> ()
    
    var rowCount: Int {
        month.isSansculottides ? 1 : 6
    }
    
    var colCount: Int {
        month.isSansculottides ? 10 : 5
    }

    var body: some View {
        let today = FrenchRepublicanDate(date: .now)
        let isCurrentMonth = today.monthIndex == month.monthIndex
        let todayDay = isCurrentMonth ? today.components.day : nil
        Button {
            selectMonth(month)
        } label: {
            VStack {
                HStack {
                    Text(month, format: .republicanDate.day(.monthOnly))
                        .lineLimit(1)
                        .font(.headline)
                        .foregroundStyle(isCurrentMonth ? Color.accentColor : .primary)
                    Spacer(minLength: 0)
                }
                .padding(.top)
                .padding(.horizontal, 4)
                FastGrid(rowCount: rowCount, colCount: colCount) {
                    ForEach(0..<(rowCount * colCount), id: \.self) { index in
                        let day = index + 1
                        let date = FrenchRepublicanDate(day: day, month: month.components.month!, year: month.year)
                        YearDateItem(
                            date: date.year == month.year ? date : nil,
                            isToday: day == todayDay
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
            .foregroundStyle(.foreground)
        }
    }
}

struct YearDateItem: View {
    var date: FrenchRepublicanDate?
    var isToday: Bool = false

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
        Text(isValid ? "\(date!.components.day!)" : "0")
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(
                !isValid ? .clear
                : isToday ? .white
                : isWeekend ? .secondary
                : .primary)
            .frame(maxWidth: .infinity)
            .padding(4)
            .minimumScaleFactor(1/3)
            .aspectRatio(1, contentMode: .fill)
            .background(Circle().fill(
                Color.accentColor.opacity(
                    isToday ? 1 : 0
                )
            ))
    }
}
