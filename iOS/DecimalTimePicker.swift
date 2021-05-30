//
//  DecimalTimePicker.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 30/05/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct DecimalTimePicker: View {
    @Binding var time: DecimalTime
    
    var body: some View {
        HStack(spacing: 0) {
            NavigatingPicker(
                selection: $time.hour.wrapped,
                range: 0..<10,
                preferMenu: true,
                title: "Heure décimale"
            )
            Text(" : ").accessibility(hidden: true)
            NavigatingPicker(
                selection: $time.minute.wrapped,
                range: 0..<100,
                preferMenu: true,
                title: "Minute décimale",
                transformer: padInt2
            )
            Text(" : ").accessibility(hidden: true)
            NavigatingPicker(
                selection: $time.second.wrapped,
                range: 0..<100,
                preferMenu: true,
                title: "Seconde décimale",
                transformer: padInt2
            )
        }.layoutPriority(10)
        .font(.title.monospacedDigit())
    }
}

struct SITimePicker: View {
    @Binding var time: DecimalTime
    
    var body: some View {
        HStack(spacing: 0) {
            NavigatingPicker(
                selection: $time.hourSI.wrapped,
                range: 0..<24,
                preferMenu: true,
                title: "Heure SI"
            )
            Text(" : ").accessibility(hidden: true)
            NavigatingPicker(
                selection: $time.minuteSI.wrapped,
                range: 0..<60,
                preferMenu: true,
                title: "Minute SI",
                transformer: padInt2
            )
            Text(" : ").accessibility(hidden: true)
            NavigatingPicker(
                selection: $time.secondSI.wrapped,
                range: 0..<60,
                preferMenu: true,
                title: "Seconde SI",
                transformer: padInt2
            )
        }.layoutPriority(10)
        .font(.title.monospacedDigit())
    }
}

fileprivate func padInt2(value: Int) -> String {
    String("0\(value)".suffix(2))
}
