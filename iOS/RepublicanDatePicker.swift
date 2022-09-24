//
//  RepublicanDatePicker.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct RepublicanDatePicker: View {
    @Binding var date: MyRepublicanDateComponents
    
    var body: some View {
        HStack(spacing: 0) {
            NavigatingPicker(
                selection: $date.day.wrapped,
                range: 1..<(date.month < 13 ? 31 : FrenchRepublicanDateOptions.current.variant.isYearSextil(date.year) ? 7 : 6),
                preferMenu: true,
                title: "Jour"
            )
            Text(" ").accessibility(hidden: true)
            NavigatingPicker(
                selection: $date.month.wrapped,
                range: 1..<14,
                preferMenu: true,
                title: "Mois",
                transformer: {
                    FrenchRepublicanDate.allMonthNames[$0 - 1]
                }
            )
            Text(" ").accessibility(hidden: true)
            NavigatingPicker(
                selection: $date.year.wrapped,
                range: 1..<2708,
                preferMenu: false,
                title: "Année",
                transformer: {
                    FrenchRepublicanDate(dayInYear: 1, year: $0).formattedYear
                }
            )
        }.layoutPriority(10)
    }
}

struct NavigatingPicker: View {
    @Binding var selection: IntWrapper
    var range: Range<Int>
    var preferMenu: Bool
    var title: String
    var transformer: (Int) -> String = String.init
    
    var body: some View {
        Group {
            if preferMenu, #available(iOS 14, *) {
                Picker(selection: $selection, label: Text(transformer(selection.value))) {
                    ForEach(range, id: \.self) { value in
                        Text(transformer(value)).tag(value.wrapped)
                    }
                }.pickerStyle(MenuPickerStyle())
            } else {
                NavigationLink(destination: NavigatedPicker(selection: $selection, range: range, title: title, transformer: transformer)) {
                    Text(transformer(selection.value))
                }
            }
        }
        .accessibility(value: Text(transformer(selection.value)))
        .accessibility(label: Text(title))
        .accessibilityAdjustableAction(with: $selection, in: range)
        .padding(5)
        .background(Color("PickerBackground").cornerRadius(5))
    }
}

struct NavigatedPicker: View {
    @Binding var selection: IntWrapper
    var range: Range<Int>
    var title: String
    var transformer: (Int) -> String
    
    var body: some View {
        Form {
            Picker(selection: $selection, label: EmptyView()) {
                ForEach(range, id: \.self) { value in
                    Text(transformer(value)).tag(value.wrapped)
                }
            }.pickerStyle(WheelPickerStyle())
            .accessibilityElement(children: .ignore)
            .accessibility(value: Text(String(selection.value)))
            .accessibility(label: Text(title))
            .accessibilityAdjustableAction(with: $selection, in: range)
        }.navigationBarTitle(Text(title))
        .listNotTooWide()
    }
}

struct MyRepublicanDateComponents {
    var day: Int
    var month: Int
    var year: Int
    
    var toRep: FrenchRepublicanDate {
        return FrenchRepublicanDate(dayInYear: (month - 1) * 30 + day, year: year)
    }
}

extension Date {
    var iso: String {
        let cmps = Calendar.gregorian.dateComponents([.year, .month, .day], from: self)
        return "\(cmps.year!)-\(cmps.month!)-\(cmps.day!)"
    }
}

extension View {
    func accessibilityAdjustableAction(with selection: Binding<IntWrapper>, in range: Range<Int>) -> some View {
        self.accessibilityAdjustableAction { direction in
            let add: Int
            switch direction {
            case .increment:
                add = 1
            case .decrement:
                add = -1
            @unknown default:
                add = 0
            }
            let new = selection.wrappedValue.value + add
            if range.contains(new) {
                selection.wrappedValue.value = new
            }
        }
    }
}
