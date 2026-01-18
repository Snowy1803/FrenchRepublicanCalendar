//
//  EventVC.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 02/11/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
import EventKit
import EventKitUI

struct EventDetailsView: View {
    @EnvironmentObject var store: EventStore
    @ObservedObject var event: EventModel
    
    @State private var showEdit: Bool = false
    @State private var showDelete: Bool = false
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        EventDetailsContent(event: event)
            .navigationTitle("Détails de l'évènement")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(store.objectWillChange) {
                if !event.event!.refresh() {
                    dismiss()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Modifier") {
                        showEdit = true
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Supprimer l'évènement", role: .destructive) {
                        showDelete = true
                    }
                    .confirmationDialog("Supprimer", isPresented: $showDelete, titleVisibility: .hidden) {
                        if event.event!.hasRecurrenceRules {
                            Button("Supprimer celui-ci seulement", role: .destructive) {
                                try? store.store.remove(event.event!, span: .thisEvent)
                                dismiss()
                            }
                            Button("Supprimer tous les évènements", role: .destructive) {
                                try? store.store.remove(event.event!, span: .futureEvents)
                                dismiss()
                            }
                        } else {
                            Button("Supprimer l'évènement", role: .destructive) {
                                try? store.store.remove(event.event!, span: .thisEvent)
                                dismiss()
                            }
                        }
                    } message: {
                        Text("Voulez-vous vraiment supprimer cet évènement\(event.event!.hasRecurrenceRules ? " récurrent" : "") ?")
                    }
                }
            }
            .sheet(isPresented: $showEdit) {
                NavigationView {
                    // Creates Model copy to edit
                    EditEventView(store: store, event: event.event!)
                }
            }
    }
}

struct EventDetailsContent: View {
    @EnvironmentObject var store: EventStore
    @ObservedObject var event: EventModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .lineLimit(2)
                        .font(.title)
                    if !event.location.isEmpty {
                        Text(event.location)
                    }
                }.padding([.top, .horizontal])
                
                VStack(alignment: .leading) {
                    let start = FrenchRepublicanDate(date: event.startDate)
                    let end = FrenchRepublicanDate(date: event.endDate)
                    if Calendar.gregorian.isDate(event.startDate, inSameDayAs: event.endDate) {
                        Text("\(start, format: .republicanDate.day().year())")
                        if event.isAllDay {
                            Text("Toute la journée")
                        } else {
                            Text("de \(start.decimalTime, format: .decimalTime.hour().minute()) à \(end.decimalTime, format: .decimalTime.hour().minute())")
                        }
                    } else {
                        Text("Du \(start, format: .republicanDate.day().year().hour().minute())")
                        Text("au \(end, format: .republicanDate.day().year().hour().minute())")
                    }
                    if let recc = event.event!.recurrenceRules?.first {
                        switch recc.frequency {
                        case .daily:
                            if recc.interval == 1 {
                                Text("Se répète tous les jours")
                            } else {
                                Text("Se répète tous les \(recc.interval) jours")
                            }
                        case .weekly:
                            if recc.interval == 1 {
                                Text("Se répète toutes les semaines grégoriennes")
                            } else {
                                Text("Se répète toutes les \(recc.interval) semaines grégoriennes")
                            }
                        case .monthly:
                            if recc.interval == 1 {
                                Text("Se répète tous les mois grégoriens")
                            } else {
                                Text("Se répète tous les \(recc.interval) mois grégoriens")
                            }
                        case .yearly:
                            if recc.interval == 1 {
                                Text("Se répète tous les ans grégoriens")
                            } else {
                                Text("Se répète tous les \(recc.interval) ans")
                            }
                        @unknown default:
                            Text("Se répète")
                        }
                    }
                }.foregroundStyle(.secondary)
                    .padding()
                
                List {
                    CalendarPicker(calendar: Binding {
                        event.calendar
                    } set: { newValue in
                        event.calendar = newValue
                        try? store.store.save(event.event!, span: .futureEvents)
                    })
                    AlarmPicker(alarms: $event.alarms, index: 0)
                        .onReceive(event.objectWillChange) {
                            DispatchQueue.main.async {
                                event.saveChanges(span: .thisEvent)
                            }
                        }
                    if !event.alarms.isEmpty {
                        AlarmPicker(alarms: $event.alarms, index: 1)
                    }
                    if let url = event.event!.url {
                        VStack(alignment: .leading) {
                            Text("URL")
                            Link(destination: url) {
                                Text(url.absoluteString)
                            }.foregroundStyle(.tint)
                        }
                    }
                    if !event.notes.isEmpty {
                        let notesText = Text((try? AttributedString(markdown: event.notes, options: .init(allowsExtendedAttributes: false, interpretedSyntax: .inlineOnlyPreservingWhitespace, failurePolicy: .returnPartiallyParsedIfPossible))) ?? AttributedString(event.notes))
                        VStack(alignment: .leading) {
                            NavigationLink(destination: ScrollView {
                                VStack(alignment: .leading) {
                                    notesText
                                        .multilineTextAlignment(.leading)
                                        .navigationTitle("Notes")
                                    Spacer()
                                }
                            }) {
                                HStack {
                                    Text("Notes")
                                    Spacer()
                                    Text("Afficher plus")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            notesText
                                .lineLimit(8)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
                .frame(height: 400)
                .scrollDisabled(true)
            }
        }
        .multilineTextAlignment(.leading)
    }
}

struct EventVC: UIViewControllerRepresentable {
    typealias UIViewControllerType = EKEventViewController
    
    let event: EKEvent
    
    func makeUIViewController(context: Context) -> EKEventViewController {
        EKEventViewController()
    }
    
    func updateUIViewController(_ uiViewController: EKEventViewController, context: Context) {
        uiViewController.event = event
    }
}
