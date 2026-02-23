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
