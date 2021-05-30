//
//  DecimalTimeView.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 30/05/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct DecimalTimeView: View {
    @State private var shownTime = DecimalTime()
    
    var body: some View {
        VStack {
            CurrentDecimalTime().padding([.top, .bottom], 5)
            Text("Temps décimal").font(.system(size: 10))
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
            Text("Temps SI").font(.system(size: 10))
        }.navigationBarTitle("Temps décimal")
        .labelsHidden()
    }
}

struct CurrentDecimalTime: View {
    let timer = Timer.publish(every: DecimalTime.decimalSecond / 10, on: .main, in: .common).autoconnect()
    
    @State private var time = DecimalTime()
    
    var body: some View {
        (
            Text(time.description)
                .font(.body.monospacedDigit())
            + Text(String(format: "%.1f", time.remainder).dropFirst())
                .font(.caption.monospacedDigit())
        ).onReceive(timer) { _ in
            self.time = DecimalTime()
        }.accessibility(label: Text("\(time.hour) heures, \(time.minute) minutes, et \(time.second) secondes"))
    }
}
