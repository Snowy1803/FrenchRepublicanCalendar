//
//  EventDetailsView.swift
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
import Combine
import EventKit

struct EventDetailsView: View {
    @EnvironmentObject var midnight: Midnight
    var date: FrenchRepublicanDate
    let store = (UIApplication.shared.delegate as! AppDelegate).eventStore

    var body: some View {
        let eventAccess = EKEventStore.authorizationStatus(for: .event)
        if eventAccess == .denied {
            VStack(alignment: .leading) {
                Text("Accès refusé")
                    .font(.headline)
                Text("Autorisez l'accès au Calendrier dans les Réglages iOS")
            }
        } else if eventAccess == .restricted {
            VStack(alignment: .leading) {
                Text("Accès restreint")
                    .font(.headline)
                Text("Autorisez l'accès au Calendrier dans les Réglages iOS")
            }
        } else if eventAccess == .notDetermined {
            VStack(alignment: .leading) {
                Text("Autorisez l'accès au Calendrier afin d'afficher tous vos évènements dans le Calendrier Républicain")
                HStack {
                    Button {
                        Task {
                            if #available(iOS 17.0, *) {
                                try await store.requestFullAccessToEvents()
                            } else {
                                try await store.requestAccess(to: .event)
                            }
                            midnight.objectWillChange.send()
                        }
                    } label: {
                        Text("Autoriser")
                    }
                }
                .prominentButtonStyle()
            }
        } else {
            AccessEventDetailsView(date: date, store: store)
        }
    }
}

struct AccessEventDetailsView: View {
    var date: FrenchRepublicanDate
    var store: EKEventStore
    @State var events: [EKEvent] = []
    @State var loading: Bool = true

    var body: some View {
        Group {
            if loading {
                ProgressView()
            } else if events.isEmpty {
                Text("Aucun évènement ce jour-là")
            }
            ForEach(events, id: \.calendarItemIdentifier) { event in
                SingleEventView(event: event)
            }
            CreateEventButton(store: store, date: date)
        }.task {
            reloadEvents()
        }.onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged, object: store)) { _ in
            reloadEvents()
        }
    }
    
    func reloadEvents() {
        let start = Calendar.gregorian.startOfDay(for: date.date)
        let end = Calendar.gregorian.date(byAdding: .day, value: 1, to: start)!
        let evPred = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let resultingEvents = store.events(matching: evPred)
        Task { @MainActor in
            self.events = resultingEvents.sorted(by: { lhs, rhs in
                lhs.compareStartDate(with: rhs) == .orderedAscending
            })
            self.loading = false
        }
    }
}

struct SingleEventView: View {
    let event: EKEvent

    var body: some View {
        NavigationLink(destination: EventVC(event: event)) {
            HStack(alignment: .firstTextBaseline) {
                Image.decorative(systemName: "circle.fill")
                    .foregroundStyle(Color(cgColor: event.calendar.cgColor))
                VStack(alignment: .leading) {
                    Text(event.title)
                    Group {
                        if event.isAllDay {
                            Text("Toute la journée")
                        } else {
                            let singleDay = Calendar.gregorian.isDate(event.startDate, inSameDayAs: event.endDate)
                            
                            let format = FRCFormat.republicanDate
                                .day(singleDay ? .none : .preferred)
                                .hour().minute()
                            Text("\(FrenchRepublicanDate(date: event.startDate), format: format) - \(FrenchRepublicanDate(date: event.endDate), format: format)")
                            
                        }
                    }.foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct CreateEventButton: View {
    let store: EKEventStore
    let date: FrenchRepublicanDate
    @State var sheet: Bool = false

    var body: some View {
        Button {
            sheet = true
        } label: {
            HStack {
                Image.decorative(systemName: "plus")
                Text("Nouvel évènement")
            }
        }.sheet(isPresented: $sheet) {
            CreateEventVC(store: store, date: date)
                .ignoresSafeArea()
                .interactiveDismissDisabled()
        }
    }
}
