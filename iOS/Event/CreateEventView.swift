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
    @EnvironmentObject var store: EventStore
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var event: EventModel
    
    init(store: EventStore, date: FrenchRepublicanDate) {
        self._event = StateObject(wrappedValue: EventModel(store: store, date: date))
    }
    
    var body: some View {
        EventEditorView(event: event)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Ajouter") {
                    event.createNewEvent()
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
    @EnvironmentObject var store: EventStore
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var event: EventModel
    @State private var recurringConfirm = false
    
    init(store: EventStore, event: EKEvent) {
        self._event = StateObject(wrappedValue: EventModel(store: store, event: event))
    }
    
    var body: some View {
        EventEditorView(event: event)
            .onReceive(store.objectWillChange) {
                if event.event!.refresh() {
                    event.refreshUnchanged()
                } else {
                    dismiss()
                }
            }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("OK") {
                    if event.event!.hasRecurrenceRules {
                        recurringConfirm = true
                    } else {
                        event.saveChanges(span: .thisEvent)
                        dismiss()
                    }
                }.disabled(event.startDate > event.endDate)
                .confirmationDialog("Modifier", isPresented: $recurringConfirm, titleVisibility: .hidden) {
                    Button("Modifier celui-ci seulement") {
                        event.saveChanges(span: .thisEvent)
                        dismiss()
                    }
                    Button("Modifier tous ceux à venir") {
                        event.saveChanges(span: .futureEvents)
                        dismiss()
                    }
                } message: {
                    Text("Cet évènement est récurrent.")
                }
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
    @EnvironmentObject var store: EventStore
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
                        Text("Jamais").tag(nil as RecurrenceModel?)
                    }
                    if event.recurrence == .unsupported {
                        RecurrenceText(recc: event.event!.recurrenceRules?.first)
                            .tag(RecurrenceModel.unsupported)
                    }
                    Text("Tous les jours").tag(RecurrenceModel.daily(interval: 1))
                    Text("Tous les 5 jours (démie-décade)").tag(RecurrenceModel.daily(interval: 5))
                    Text("Tous les 10 jours (décade)").tag(RecurrenceModel.daily(interval: 10))
                    Text("Tous les 15 jours (2 fois par mois)").tag(RecurrenceModel.daily(interval: 15))
                    Text("Tous les 30 jours (1 fois par mois)").tag(RecurrenceModel.daily(interval: 30))
                    Text("Tous les ans").tag(RecurrenceModel.yearly)
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
                CalendarPicker(calendar: Binding { event.calendar ?? store.store.defaultCalendarForNewEvents } set: { event.calendar = $0 })
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
