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

struct RepublicanDatePicker: View {
    @State private var month: FrenchRepublicanDate
    @Binding var selection: FrenchRepublicanDate
    @Environment(\.horizontalSizeClass) var sizeClass
    
    init(selection: Binding<FrenchRepublicanDate>) {
        self.month = selection.wrappedValue
        self._selection = selection
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(month, format: .republicanDate.day(.monthOnly).year(.long))
                    .padding()
                Spacer()
                Button {
                    previousMonth()
                } label: {
                    Image(systemName: "chevron.left")
                        .padding()
                        .foregroundStyle(.foreground)
                }
                Button {
                    nextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .padding()
                        .foregroundStyle(.foreground)
                }
            }
            .font(.headline)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Mois"))
            .accessibilityValue(Text(month, format: .republicanDate.day(.monthOnly).year(.long)))
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    nextMonth()
                case .decrement:
                    previousMonth()
                @unknown default:
                    ()
                }
            }
            CalendarMonthView(month: month, selection: $selection, halfWeek: sizeClass == .compact, constantHeight: true)
        }
    }
    
    func previousMonth() {
        if month.components.month! == 1 {
            month = FrenchRepublicanDate(
                day: 1,
                month: 13,
                year: self.month.components.year! - 1
            )
        } else {
            month = FrenchRepublicanDate(
                day: 1,
                month: self.month.components.month! - 1,
                year: self.month.components.year!
            )
        }
    }
    
    func nextMonth() {
        if month.isSansculottides {
            month = FrenchRepublicanDate(
                day: 1,
                month: 1,
                year: self.month.components.year! + 1
            )
        } else {
            month = FrenchRepublicanDate(
                day: 1,
                month: self.month.components.month! + 1,
                year: self.month.components.year!
            )
        }

    }
}

struct FoldableDatePicker: View {
    var si: Bool
    var label: Text
    @Binding var date: Date
    @Binding var showPicker: Bool
    
    var value: Text {
        if si {
            Text(date,
                 format: .dateTime.day().month(.wide).year())
        } else {
            Text(FrenchRepublicanDate(date: date),
                 format: .republicanDate.day(.preferred).year(.long))
        }
    }
    
    var body: some View {
        FoldablePicker(label: label, value: value, showPicker: $showPicker) {
            if si {
                DatePicker(selection: $date, in: FrenchRepublicanDate.origin..., displayedComponents: .date) {
                    label
                }.frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.locale, Locale(identifier: "fr"))
                .datePickerStyle(.graphical)
                .labelsHidden()
            } else {
                RepublicanDatePicker(selection: Binding {
                    FrenchRepublicanDate(date: date)
                } set: {
                    date = $0.date
                })
            }
        }
    }
}
