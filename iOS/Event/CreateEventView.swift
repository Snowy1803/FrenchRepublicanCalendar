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
    @State private var travelTime: DecimalTime = .midnight
    @State private var recurrence: Int? = nil
    @State private var recurrenceEnd: Date? = nil
    @State private var calendar: EKCalendar? = nil
    
    
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
                if !isAllDay {
                    Picker("Temps de trajet", selection: $travelTime) {
                        Text("Aucun").tag(DecimalTime.midnight)
                        Text("5 minutes").tag(DecimalTime(hour: 0, minute: 5, second: 0, remainder: 0))
                        Text("10 minutes").tag(DecimalTime(hour: 0, minute: 10, second: 0, remainder: 0))
                        Text("20 minutes").tag(DecimalTime(hour: 0, minute: 20, second: 0, remainder: 0))
                        Text("40 minutes").tag(DecimalTime(hour: 0, minute: 40, second: 0, remainder: 0))
                        Text("60 minutes").tag(DecimalTime(hour: 0, minute: 60, second: 0, remainder: 0))
                        Text("80 minutes").tag(DecimalTime(hour: 0, minute: 80, second: 0, remainder: 0))
                        Text("1 heure").tag(DecimalTime(hour: 1, minute: 0, second: 0, remainder: 0))
                    }
                }
            } footer: {
                if startDate > endDate {
                    Text("L'évènement ne peut pas finir avant d'avoir commencé.")
                        .foregroundStyle(.red)
                } else {
                    Text("Tous les temps utilisent le temps décimal.")
                }
            }
            .buttonStyle(.borderless)
            Section {
                Picker("Récurrence", selection: $recurrence) {
                    Text("Jamais").tag(nil as Int?)
                    Text("Tous les jours").tag(1)
                    Text("Tous les 5 jours (démie-décade)").tag(5)
                    Text("Tous les 10 jours (décade)").tag(10)
                    Text("Tous les 15 jours (2 fois par mois)").tag(15)
                    Text("Tous les 30 jours (1 fois par mois)").tag(30)
                    Text("Tous les ans").tag(365)
                }
                if recurrence != nil {
                    Picker("Fin de la récurrence", selection: Binding { recurrenceEnd != nil } set: { recurrenceEnd = $0 ? startDate : nil }) {
                        Text("Jamais").tag(false)
                        Text("Le").tag(true)
                    }
                    if recurrenceEnd != nil {
                        FoldableDateTimePicker(
                            label: Text("Date de fin"),
                            precision: .decimalTime,
                            date: Binding { recurrenceEnd ?? startDate } set: { recurrenceEnd = $0 },
                            showDatePicker: $shownPicker[is: 5], showTimePicker: .constant(false)
                        )
                    }
                }
            }
            .buttonStyle(.borderless)
            
            Section {
                CalendarPicker(store: store, calendar: Binding { calendar ?? store.defaultCalendarForNewEvents } set: { calendar = $0 })
            }
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
                    event.calendar = calendar ?? store.defaultCalendarForNewEvents
                    if !isAllDay {
                        event.setValue(Int(travelTime.timeSinceMidnight), forKey: "travelTime")
                    }
                    if let recurrence {
                        event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .daily, interval: recurrence, end: recurrenceEnd.flatMap { EKRecurrenceEnd(end: $0)} ))
                    }
                    try? store.save(event, span: .futureEvents)
                    dismiss()
                }.disabled(startDate > endDate)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
        }
        .navigationTitle("Nouvel évènement")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CalendarPicker: View {
    var store: EKEventStore
    @Binding var calendar: EKCalendar?

    var body: some View {
        Picker("Calendrier", selection: $calendar) {
            ForEach(store.sources, id: \.sourceIdentifier) { source in
                Section(source.title) {
                    let calendars: [EKCalendar] = store.calendars(for: .event).filter { calendar in
                        calendar.source == source && calendar.allowsContentModifications
                    }
                    ForEach(calendars, id: \.calendarIdentifier) { calendar in
                        Label {
                            Text(calendar.title)
                        } icon: {
                            Image(systemName: "circlebadge.fill")
                                .imageScale(.small)
                                .foregroundStyle(Color(cgColor: calendar.cgColor), .white)
                        }
                        .tag(calendar)
                    }
                }
            }
        }
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
