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
    
    @StateObject private var event: EventModel
    
    init(store: EKEventStore, date: FrenchRepublicanDate) {
        self.store = store
        self._event = StateObject(wrappedValue: EventModel(date: date))
    }
    
    var body: some View {
        EventEditorView(store: store, event: event)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Ajouter") {
                    event.createNewEvent(store: store)
                    dismiss()
                }.disabled(event.startDate > event.endDate)
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

struct EditEventView: View {
    var store: EKEventStore
    var backingEvent: EKEvent
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var event: EventModel
    
    init(store: EKEventStore, event: EKEvent) {
        self.store = store
        self.backingEvent = event
        self._event = StateObject(wrappedValue: EventModel(event: event))
    }
    
    var body: some View {
        EventEditorView(store: store, event: event)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("OK") {
                    event.saveChanges(event: backingEvent, store: store, span: .thisEvent)
                    dismiss()
                }.disabled(event.startDate > event.endDate)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
        }
        .navigationTitle("Modifier l'évènement")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EventEditorView: View {
    var store: EKEventStore
    @State private var shownPicker: Int = 0
    
    // Properties
    @ObservedObject var event: EventModel
    
    var body: some View {
        Form {
            Section {
                TextField("Titre", text: $event.title)
                TextField("Lieu ou appel vidéo", text: $event.location)
                    .textContentType(.location)
            }
            Section {
                Toggle(isOn: Binding {
                    event.isAllDay
                } set: {
                    event.isAllDay = $0
                    shownPicker = 0
                }) {
                    Text("Jour entier")
                }
                FoldableDateTimePicker(
                    label: Text("Début"),
                    precision: event.isAllDay ? .decimalTime : .decimalTime.hour().minute(),
                    date: $event.startDate,
                    showDatePicker: $shownPicker[is: 1],
                    showTimePicker: $shownPicker[is: 2]
                ).transition(.identity)
                FoldableDateTimePicker(
                    label: Text("Fin"),
                    precision: event.isAllDay ? .decimalTime : .decimalTime.hour().minute(),
                    date: $event.endDate,
                    showDatePicker: $shownPicker[is: 3],
                    showTimePicker: $shownPicker[is: 4]
                ).transition(.identity)
                if !event.isAllDay {
                    TravelTimePicker(travelTime: $event.travelTime)
                }
            } footer: {
                if event.startDate > event.endDate {
                    Text("L'évènement ne peut pas finir avant d'avoir commencé.")
                        .foregroundStyle(.red)
                } else {
                    Text("Tous les temps utilisent le temps décimal.")
                }
            }
            .buttonStyle(.borderless)
            Section {
                Picker("Récurrence", selection: $event.recurrence) {
                    Section {
                        Text("Jamais").tag(nil as Int?)
                    }
                    Text("Tous les jours").tag(1)
                    Text("Tous les 5 jours (démie-décade)").tag(5)
                    Text("Tous les 10 jours (décade)").tag(10)
                    Text("Tous les 15 jours (2 fois par mois)").tag(15)
                    Text("Tous les 30 jours (1 fois par mois)").tag(30)
                    Text("Tous les ans").tag(365)
                }
                if event.recurrence != nil {
                    Picker("Fin de la récurrence", selection: Binding { event.recurrenceEnd != nil } set: { event.recurrenceEnd = $0 ? event.startDate : nil }) {
                        Text("Jamais").tag(false)
                        Text("Le").tag(true)
                    }
                    if event.recurrenceEnd != nil {
                        FoldableDateTimePicker(
                            label: Text("Date de fin"),
                            precision: .decimalTime,
                            date: Binding { event.recurrenceEnd ?? event.startDate } set: { event.recurrenceEnd = $0 },
                            showDatePicker: $shownPicker[is: 5], showTimePicker: .constant(false)
                        )
                    }
                }
            }
            .buttonStyle(.borderless)
            
            Section {
                CalendarPicker(store: store, calendar: Binding { event.calendar ?? store.defaultCalendarForNewEvents } set: { event.calendar = $0 })
            }
            
            Section {
                AlarmPicker(alarms: $event.alarms, index: 0)
                if !event.alarms.isEmpty {
                    AlarmPicker(alarms: $event.alarms, index: 1)
                }
            }
            
            Section {
                TextField("URL", text: $event.url)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Notes", text: $event.notes, axis: .vertical)
                    .lineLimit(7...7)
            }
        }
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
