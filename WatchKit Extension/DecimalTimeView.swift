//
//  DecimalTimeView.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 30/05/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct DecimalTimeView: View {
    @State private var shownTime = DecimalTime()
    
    var body: some View {
        VStack {
            CurrentDecimalTimeline().padding([.top, .bottom], 5)
            Text("Temps décimal").font(.system(size: 11))
            HStack {
                Picker(selection: $shownTime.hour.wrapped, label: Text("Heure décimale")) {
                    ForEach(0..<10) { h in
                        Text("\(h)").tag(h.wrapped)
                    }
                }
                Picker(selection: $shownTime.minute.wrapped, label: Text("Minute décimale")) {
                    ForEach(0..<100) { m in
                        Text("0\(m)".suffix(2)).tag(m.wrapped)
                    }
                }
                Picker(selection: $shownTime.second.wrapped, label: Text("Seconde décimale")) {
                    ForEach(0..<100) { s in
                        Text("0\(s)".suffix(2)).tag(s.wrapped)
                    }
                }
            }
            HStack {
                Picker(selection: $shownTime.hourSI.wrapped, label: Text("Heure SI")) {
                    ForEach(0..<24) { h in
                        Text("\(h)").tag(h.wrapped)
                    }
                }
                Picker(selection: $shownTime.minuteSI.wrapped, label: Text("Minute SI")) {
                    ForEach(0..<60) { m in
                        Text("0\(m)".suffix(2)).tag(m.wrapped)
                    }
                }
                Picker(selection: $shownTime.secondSI.wrapped, label: Text("Seconde SI")) {
                    ForEach(0..<60) { s in
                        Text("0\(s)".suffix(2)).tag(s.wrapped)
                    }
                }
            }
            Text("Temps SI").font(.system(size: 11))
                .padding(.bottom)
        }.navigationBarTitle("Temps décimal")
        .ensureSmallBarTitle()
        .labelsHidden()
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct CurrentDecimalTimeline: View {
    var body: some View {
        TimelineView(.periodic(from: Calendar.gregorian.startOfDay(for: Date()), by: DecimalTime.decimalSecond / 10)) { context in
            let time = DecimalTime(base: context.date)
            #if DEBUG
            let _ = print(context.date, context.cadence, time.description)
            #endif
            (
                Text(context.cadence <= .seconds ? time.hourMinuteSecondsFormatted : time.hourAndMinuteFormatted)
                    .font(.body.monospacedDigit())
                + Text(context.cadence == .live ? String(format: "%.1f", time.remainder).dropFirst() : "")
                    .font(.caption.monospacedDigit())
            ).accessibility(label: Text("\(time.hour) heures, \(time.minute) minutes, et \(time.second) secondes"))
        }
    }
}
