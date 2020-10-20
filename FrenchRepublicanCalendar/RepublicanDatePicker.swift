//
//  RepublicanDatePicker.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

struct RepublicanDatePicker: View {
    @Binding var date: MyRepublicanDateComponents
    
    var body: some View {
        HStack(spacing: 0) {
            NavigatingPicker(
                selection: $date.day.wrapped,
                range: 1..<(date.month < 13 ? 31 : date.year % 4 == 0 ? 7 : 6),
                preferMenu: true,
                title: "Jour"
            )
            Text(" ")
            NavigatingPicker(
                selection: $date.month.wrapped,
                range: 1..<14,
                preferMenu: true,
                title: "Mois",
                transformer: {
                    FrenchRepublicanDate.MONTH_NAMES[$0 - 1]
                }
            )
            Text(" ")
            NavigatingPicker(
                selection: $date.year.wrapped,
                range: 0..<2708,
                preferMenu: false,
                title: "Année"
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
                NavigationLink(destination: NavigatedPicker(selection: $selection, range: range, title: title)) {
                    Text(String(selection.value))
                }
            }
        }
        .padding(5)
        .background(Color("PickerBackground").cornerRadius(5))
    }
}

struct NavigatedPicker: View {
    @Binding var selection: IntWrapper
    var range: Range<Int>
    var title: String
    
    var body: some View {
        Form {
            Picker(selection: $selection, label: EmptyView()) {
                ForEach(range, id: \.self) { value in
                    Text(String(value)).tag(value.wrapped)
                }
            }.pickerStyle(WheelPickerStyle())
        }.navigationBarTitle(Text(title))
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
        let cmps = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return "\(cmps.year!)-\(cmps.month!)-\(cmps.day!)"
    }
}
