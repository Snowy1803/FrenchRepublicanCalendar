//
//  WatchCalendarView.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil Pedersen on 05/02/2026.
//  Copyright © 2026 Snowy_1803. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct WatchCalendarView: View {
    @State private var scrolled = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Show a range of months around the current date
                    ForEach(monthRange, id: \.self) { monthOffset in
                        let month = monthForOffset(monthOffset)
                        WatchCalendarMonthSection(month: month)
                            .id(monthOffset)
                    }
                }
                .padding(.horizontal, 4)
            }
            .onAppear {
                if !scrolled {
                    scrolled = true
                    proxy.scrollTo(0, anchor: .top)
                }
            }
        }
        .navigationBarTitle("Calendrier")
        .ensureSmallBarTitle()
    }
    
    // Range of months to display (a year before and after current)
    var monthRange: ClosedRange<Int> {
        -13...13
    }
    
    func monthForOffset(_ offset: Int) -> FrenchRepublicanDate {
        let today = FrenchRepublicanDate(date: .now)
        var month = today.components.month! + offset
        var year = today.year
        
        while month < 1 {
            month += 13
            year -= 1
        }
        while month > 13 {
            month -= 13
            year += 1
        }
        
        return FrenchRepublicanDate(day: 1, month: month, year: year)
    }
}

struct WatchCalendarMonthSection: View {
    var month: FrenchRepublicanDate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Month header
            Text(month, format: .republicanDate.day(.monthOnly).year())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
            
            // Calendar grid - always half weeks (5 columns)
            WatchCalendarMonthGrid(month: month)
        }
    }
}

struct WatchCalendarMonthGrid: View {
    var month: FrenchRepublicanDate
    
    var rowCount: Int {
        if month.isSansculottides {
            month.isYearSextil ? 2 : 1
        } else {
            6  // Always 6 rows for half-weeks
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<rowCount, id: \.self) { row in
                WatchCalendarRow(month: month, row: row)
            }
        }
    }
}

struct WatchCalendarRow: View {
    var month: FrenchRepublicanDate
    var row: Int
    
    let colCount = 5  // Half-week
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<colCount, id: \.self) { col in
                let dayNum = row * colCount + col + 1
                let date = FrenchRepublicanDate(day: dayNum, month: month.components.month!, year: month.year)
                let isValid = date.year == month.year
                
                WatchCalendarDayCell(
                    date: isValid ? date : nil
                )
            }
        }
    }
}

struct WatchCalendarDayCell: View {
    var date: FrenchRepublicanDate?
    
    var isToday: Bool {
        guard let date else { return false }
        return Calendar.gregorian.isDateInToday(date.date)
    }
    
    var isWeekend: Bool {
        guard let date else { return false }
        return date.isSansculottides || date.components.day! % 10 == 0
    }
    
    var body: some View {
        if let date {
            NavigationLink(destination: ScrollableDayView(date: date)) {
                Text("\(date.components.day!)")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        isToday ? .primary
                        : isWeekend ? .secondary
                        : .primary
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(
                        isToday ? Color.accentColor : Color.clear
                    )
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        } else {
            Text("")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationView {
        WatchCalendarView()
    }
}
