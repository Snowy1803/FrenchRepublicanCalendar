//
//  CalendarPicker.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 18/01/2026.
//  Copyright © 2026 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI
import EventKit

struct CalendarPicker: View {
    @EnvironmentObject var store: EventStore
    @Binding var calendar: EKCalendar?

    var body: some View {
        Picker("Calendrier", selection: $calendar) {
            ForEach(store.groupedCalendars(editableCalendarsOnly: true), id: \.0.sourceIdentifier) { (source, calendars) in
                Section(source.title) {
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
