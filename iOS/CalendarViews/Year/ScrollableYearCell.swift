//
//  ScrollableYearCell.swift
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
struct ScrollableYearCell: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    var year: FrenchRepublicanDate
    var selectMonth: (FrenchRepublicanDate) -> ()
    
    var colCount: Int {
        if sizeClass == .regular {
            6
        } else {
            3
        }
    }

    var body: some View {
        let padding: CGFloat = sizeClass == .regular ? 32 : 8
        VStack(alignment: .leading, spacing: 0) {
            Text(year, format: .republicanDate.year())
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(FrenchRepublicanDate(date: .now).year == year.year ? Color.accentColor : .primary)
            Divider()
            FastGrid(rowCount: 12 / colCount, colCount: colCount) {
                ForEach(0..<12) { index in
                    ScrollableYearMonthView(month: FrenchRepublicanDate(day: 1, month: index + 1, year: year.year), selectMonth: selectMonth)
                }
            }
            HStack(spacing: padding) {
                GeometryReader { proxy in
                    ScrollableYearMonthView(month: FrenchRepublicanDate(day: 1, month: 13, year: year.year), selectMonth: selectMonth)
                        .frame(width: (proxy.size.width - padding * CGFloat(colCount)) * 2 / CGFloat(colCount))
                }.frame(height: 50)
            }
        }.padding(.horizontal, padding)
            .padding(.vertical)
    }
}
