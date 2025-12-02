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

struct ScrollableCalendarView: View {
    @State private var selection = FrenchRepublicanDate(date: Date())
    @State private var hasAppeared = false
    @State private var scrollToToday = false
    @State private var visible: Set<Int> = []
    
    var firstVisibleMonth: FrenchRepublicanDate {
        guard let smallestId = visible.min() else {
            return FrenchRepublicanDate(date: .now)
        }
        return MonthCollection()[smallestId]
    }
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(MonthCollection(), id: \.monthIndex) { month in
                        HStack {
                            Text(month, format: .republicanDate.day(.monthOnly).year(.long))
                                .lineLimit(1)
                                .font(.headline)
                            Spacer(minLength: 0)
                        }
                        .padding(.top)
                        .padding()
                        .onAppear {
                            visible.insert(month.monthIndex)
                        }
                        .onDisappear {
                            visible.remove(month.monthIndex)
                        }
                        CalendarMonthView(month: month, selection: $selection, constantHeight: false)
                    }
                }
            }.introspect(.scrollView, on: .iOS(.v15...)) { scrollView in
                scrollView.scrollsToTop = false
            }.onChange(of: scrollToToday) { newVal in
                if newVal {
                    selection = FrenchRepublicanDate(date: Date())
                    withAnimation {
                        reader.scrollTo(selection.monthIndex, anchor: .top)
                    }
                    scrollToToday = false
                }
            }.onAppear {
                if hasAppeared { return }
                hasAppeared = true
                DispatchQueue.main.async {
                    reader.scrollTo(selection.monthIndex, anchor: .top)
                }
            }
        }.toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    scrollToToday = true
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text(firstVisibleMonth, format: .republicanDate.year())
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    scrollToToday = true
                } label: {
                    Text("Aujourd'hui")
                }
            }
        }
        .navigationTitle(Text(firstVisibleMonth, format: .republicanDate.day(.monthOnly)))
    }
}

fileprivate extension FrenchRepublicanDate {
    var monthIndex: Int {
        (self.year - 1) * 13 + self.components.month! - 1
    }
}

struct MonthCollection: RandomAccessCollection {
    var startIndex: Int = {
        0
    }()
    var endIndex: Int {
        let max = FrenchRepublicanDate(date: FrenchRepublicanDate.maxSafeDate)
        return max.monthIndex
    }
    
    typealias Element = FrenchRepublicanDate
    typealias Index = Int
    typealias SubSequence = Array
    typealias Indices = Range<Int>
    
    subscript(position: Int) -> FrenchRepublicanDate {
        get {
            let year = position / 13 + 1
            let month = position % 13 + 1
            return FrenchRepublicanDate(day: 1, month: month, year: year)
        }
    }
}
