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

struct EventPermissionWrapperView<Content: View>: View {
    @EnvironmentObject var midnight: Midnight
    @EnvironmentObject var store: EventStore
    @ViewBuilder var wrapped: () -> Content

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
                                try await store.store.requestFullAccessToEvents()
                            } else {
                                try await store.store.requestAccess(to: .event)
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
            wrapped()
        }
    }
}

struct DayEventWrapperView<Content: View>: View {
    var date: FrenchRepublicanDate
    @EnvironmentObject var store: EventStore
    @State var events: [EventModel] = []
    @State var loading: Bool = true
    @ViewBuilder var wrapped: (Bool, [EventModel]) -> Content

    var body: some View {
        wrapped(loading, events)
        .task {
            reloadEvents(date: date)
        }.onReceive(store.objectWillChange) { _ in
            reloadEvents(date: date)
        }.onChange(of: date) { newValue in
            self.events = []
            reloadEvents(date: newValue)
        }
    }
    
    func reloadEvents(date: FrenchRepublicanDate) {
        let start = Calendar.gregorian.startOfDay(for: date.date)
        let end = Calendar.gregorian.date(byAdding: .day, value: 1, to: start)!
        let evPred = store.store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let resultingEvents = store.store.events(matching: evPred)
        Task { @MainActor in
            self.events = resultingEvents.sorted(by: { lhs, rhs in
                lhs.compareStartDate(with: rhs) == .orderedAscending
            }).map {
                EventModel(store: store, event: $0)
            }
            self.loading = false
        }
    }
}

struct EventDetailsListView: View {
    @EnvironmentObject var store: EventStore
    var date: FrenchRepublicanDate

    var body: some View {
        EventPermissionWrapperView {
            DayEventWrapperView(date: date) { loading, events in
                if loading {
                    ProgressView()
                } else if events.isEmpty {
                    Text("Aucun évènement ce jour-là")
                }
                ForEach(events) { event in
                    SingleEventView(event: event)
                }
                CreateEventButton(date: date)
            }
        }
    }
}

struct SingleEventView: View {
    @EnvironmentObject var store: EventStore
    let event: EventModel

    var body: some View {
        NavigationLink(destination: EventDetailsView(event: event)) {
            HStack(alignment: .firstTextBaseline) {
                Image.decorative(systemName: "circle.fill")
                    .foregroundStyle(Color(cgColor: event.calendar!.cgColor))
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
    @EnvironmentObject var store: EventStore
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
            NavigationView {
                CreateEventView(store: store, date: date)
            }
        }
    }
}
