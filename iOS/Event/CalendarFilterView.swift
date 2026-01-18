//
//  CalendarFilterView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 16/01/2026.
//  Copyright © 2026 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import EventKit

struct CalendarFilterView: View {
    @EnvironmentObject var store: EventStore
    
    var body: some View {
        Form {
            ForEach(store.groupedCalendars(editableCalendarsOnly: false)) { source in
                Section(source.title) {
                    ForEach(source.content, id: \.calendarIdentifier) { calendar in
                        Button {
                            store.setFiltered(calendar: calendar, show: !store.shouldShow(calendar: calendar))
                        } label: {
                            HStack {
                                Group {
                                    if store.shouldShow(calendar: calendar) {
                                        Image(systemName: "checkmark.circle.fill")
                                    } else {
                                        Image(systemName: "circle")
                                    }
                                }.foregroundStyle(Color(cgColor: calendar.cgColor))
                                    .imageScale(.large)
                                Text(calendar.title)
                            }
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
