//
//  EventPermissionWrapperView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 23/02/2026.
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
                #if os(watchOS)
                Text("Autorisez l'accès au Calendrier dans les Réglages")
                    .font(.caption)
                #else
                Text("Autorisez l'accès au Calendrier dans les Réglages iOS")
                #endif
            }
        } else if eventAccess == .restricted {
            VStack(alignment: .leading) {
                Text("Accès restreint")
                    .font(.headline)
                #if os(watchOS)
                Text("Autorisez l'accès au Calendrier dans les Réglages")
                    .font(.caption)
                #else
                Text("Autorisez l'accès au Calendrier dans les Réglages iOS")
                #endif
            }
        } else if eventAccess == .notDetermined {
            VStack(alignment: .leading) {
                #if os(watchOS)
                Text("Autoriser l'accès au Calendrier")
                    .font(.caption)
                #else
                Text("Autorisez l'accès au Calendrier afin d'afficher tous vos évènements dans le Calendrier Républicain")
                #endif
                HStack {
                    Button {
                        Task {
                            if #available(iOS 17.0, watchOS 10.0, *) {
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
                #if !os(watchOS)
                .prominentButtonStyle()
                #endif
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
