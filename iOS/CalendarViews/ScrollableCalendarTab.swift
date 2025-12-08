//
//  ScrollableCalendarTab.swift
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

@available(iOS 16.0, *)
struct ScrollableCalendarTab: View {
    enum Page { case year, month, day }
    @State private var page: Page = .month
    @State private var topItem: FrenchRepublicanDate = FrenchRepublicanDate(date: .now)

    var body: some View {
        ZStack {
            switch page {
            case .year:
                ScrollableYearView(initialLocation: topItem) { month in
                    topItem = month
                    page = .month
                }
                .transition(.move(edge: .leading))
            case .month:
                ScrollableMonthView(topItem: $topItem, selection: Binding {
                    FrenchRepublicanDate(date: .now)
                } set: {
                    topItem = $0
                    page = .day
                }) { year in
                    topItem = year
                    page = .year
                }
                .transition(.opacity)
            case .day:
                DateDetails(date: topItem)
                    .transition(.move(edge: .trailing))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button {
                                page = .month
                            } label: {
                                HStack {
                                    Image(systemName: "chevron.backward")
                                    Text(topItem, format: .republicanDate.day(.monthOnly))
                                }
                            }.labelStyle(.titleAndIcon)
                        }
                    }
            }
        }.animation(.easeInOut(duration: 0.2), value: page)
    }
}
