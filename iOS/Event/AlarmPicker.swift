//
//  AlarmPicker.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 15/01/2026.
//  Copyright © 2026 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct AlarmPicker: View {
    @Binding var alarms: [TimeInterval]
    var index: Int
    
    var selection: Binding<TimeInterval?> {
        Binding {
            if alarms.indices.contains(index) {
                alarms[index]
            } else {
                nil
            }
        } set: { newValue in
            if alarms.indices.contains(index) {
                if let newValue {
                    alarms[index] = newValue
                } else {
                    alarms.remove(at: index)
                }
            } else if let newValue {
                alarms.append(newValue)
            }
            alarms.sort()
        }
    }
    
    static let defaultChoices: [AlarmChoice] = [
        AlarmChoice(name: "À l'heure de l'évènement", time: 0),
        AlarmChoice(name: "5 minutes avant", minutes: 5),
        AlarmChoice(name: "10 minutes avant", minutes: 10),
        AlarmChoice(name: "15 minutes avant", minutes: 15),
        AlarmChoice(name: "20 minutes avant", minutes: 20),
        AlarmChoice(name: "40 minutes avant", minutes: 40),
        AlarmChoice(name: "80 minutes avant", minutes: 80),
        AlarmChoice(name: "1 heure avant", hours: 1, minutes: 0),
        AlarmChoice(name: "1 jour avant", days: 1),
        AlarmChoice(name: "2 jour avant", days: 2),
        AlarmChoice(name: "5 jour avant", days: 5),
        AlarmChoice(name: "10 jour avant", days: 10),
    ]

    var body: some View {
        Picker(index == 0 ? "Alerte" : "Deuxième alerte", selection: selection) {
            Section {
                Text("Aucune").tag(nil as TimeInterval?)
            }
            if let value = selection.wrappedValue, !AlarmPicker.defaultChoices.contains(where: { $0.time == selection.wrappedValue }) {
                if value > 0 {
                    Text("\(DecimalTime(timeSinceMidnight: value), format: .decimalTime.hour().minute().second()) avant").tag(value)
                } else {
                    Text("\(DecimalTime(timeSinceMidnight: -value), format: .decimalTime.hour().minute().second()) après").tag(value)
                }
            }
            ForEach(AlarmPicker.defaultChoices) { choice in
                Text(choice.name).tag(choice.time)
            }
        }
    }
}

struct TravelTimePicker: View {
    @Binding var travelTime: DecimalTime
    
    static let defaultChoices: [AlarmChoice] = [
        AlarmChoice(name: "5 minutes", minutes: 5),
        AlarmChoice(name: "10 minutes", minutes: 10),
        AlarmChoice(name: "20 minutes", minutes: 20),
        AlarmChoice(name: "40 minutes", minutes: 40),
        AlarmChoice(name: "60 minutes", minutes: 60),
        AlarmChoice(name: "80 minutes", minutes: 80),
        AlarmChoice(name: "1 heure", hours: 1, minutes: 0),
    ]

    var body: some View {
        Picker("Temps de trajet", selection: $travelTime) {
            Section {
                Text("Aucun").tag(DecimalTime.midnight)
            }
            if !TravelTimePicker.defaultChoices.contains(where: { $0.time == travelTime.timeSinceMidnight }) {
                Text("\(travelTime, format: .decimalTime.hour().minute().second())").tag(travelTime)
            }
            ForEach(TravelTimePicker.defaultChoices) { choice in
                Text(choice.name).tag(DecimalTime(timeSinceMidnight: choice.time))
            }
        }
    }
}

struct AlarmChoice: Identifiable {
    var name: String
    var time: TimeInterval
    
    var id: TimeInterval { time }
    
    init(name: String, time: TimeInterval) {
        self.name = name
        self.time = time
    }
    
    init(name: String, days: TimeInterval) {
        self.init(name: name, time: days * 24 * 3600)
    }
    
    init(name: String, hours: Int = 0, minutes: Int) {
        self.init(name: name, time: DecimalTime(hour: hours, minute: minutes, second: 0, remainder: 0).timeSinceMidnight)
    }
}
