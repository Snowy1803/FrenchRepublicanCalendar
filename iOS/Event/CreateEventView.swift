//
//  CreateEventView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 14/01/2026.
//  Copyright © 2026 Snowy_1803. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
import Combine
import EventKit

struct CreateEventView: View {
    var store: EKEventStore
    @Environment(\.dismiss) var dismiss
    @State private var shownPicker: Int = 0
    
    // Properties
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var isAllDay: Bool = false
    @State private var startDate: Date
    @State private var endDate: Date
    
    
    init(store: EKEventStore, date: FrenchRepublicanDate) {
        self.store = store
        self.startDate = date.date.addingTimeInterval(DecimalTime(hour: 4, minute: 0, second: 0, remainder: 0).timeSinceMidnight)
        self.endDate = date.date.addingTimeInterval(DecimalTime(hour: 4, minute: 50, second: 0, remainder: 0).timeSinceMidnight)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Titre", text: $title)
                TextField("Lieu ou appel vidéo", text: $location)
            }
            Section {
                Toggle(isOn: Binding {
                    isAllDay
                } set: {
                    isAllDay = $0
                    shownPicker = 0
                }) {
                    Text("Jour entier")
                }
                FoldableDateTimePicker(
                    label: Text("Début"),
                    precision: isAllDay ? .decimalTime : .decimalTime.hour().minute(),
                    date: $startDate,
                    showDatePicker: $shownPicker[is: 1],
                    showTimePicker: $shownPicker[is: 2]
                ).transition(.identity)
                FoldableDateTimePicker(
                    label: Text("Fin"),
                    precision: isAllDay ? .decimalTime : .decimalTime.hour().minute(),
                    date: $endDate,
                    showDatePicker: $shownPicker[is: 3],
                    showTimePicker: $shownPicker[is: 4]
                ).transition(.identity)
            }.buttonStyle(.borderless)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Ajouter") {
                    let event = EKEvent(eventStore: store)
                    event.title = title
                    event.location = location.isEmpty ? nil : location
                    event.startDate = startDate
                    event.endDate = endDate
                    event.isAllDay = isAllDay
                    event.calendar = store.defaultCalendarForNewEvents
                    try? store.save(event, span: .futureEvents)
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
        }
        .navigationTitle("Nouvel évènement")
    }
}

fileprivate extension Int {
    subscript(is expected: Int) -> Bool {
        get {
            self == expected
        }
        set {
            if newValue {
                self = expected
            } else {
                self = 0
            }
        }
    }
}
