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
        if calendar?.allowsContentModifications ?? true {
            Picker("Calendrier", selection: $calendar) {
                ForEach(store.groupedCalendars(editableCalendarsOnly: true), id: \.0.sourceIdentifier) { (source, calendars) in
                    Section(source.title) {
                        ForEach(calendars, id: \.calendarIdentifier) { calendar in
                            CalendarItem(calendar: calendar)
                        }
                    }
                }
            }
        } else if let calendar {
            // Calendar cannot be changed
            HStack {
                Label {
                    Text("Calendrier")
                } icon: {
                    // empty icon needed for the separator to not be attached to the circle badge icon
                    Image.decorative(systemName: "calendar")
                        .foregroundStyle(Color.clear)
                        .clipped()
                        .frame(width: 0, height: 0)
                }
                Spacer()
                CalendarItem(calendar: calendar)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

fileprivate struct CalendarItem: View {
    var calendar: EKCalendar

    var body: some View {
        Label {
            Text(calendar.title)
        } icon: {
            Image(systemName: "circlebadge.fill")
                .imageScale(.large)
                .foregroundStyle(Color(cgColor: calendar.cgColor), .white)
        }
        .tag(calendar)
    }
}
