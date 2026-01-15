//
//  ScrollableDayView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 05/01/2026.
//  Copyright © 2026 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Eventually
import SwiftUI
import FrenchRepublicanCalendarCore
import EventKit

fileprivate var siHourSlotHeight: CGFloat {
    50
}

fileprivate var decHourSlotHeight: CGFloat {
    siHourSlotHeight * 24 / 10
}

struct ScrollableDayView: View {
    @EnvironmentObject var midnight: Midnight
    var date: FrenchRepublicanDate
    @State private var showDetails: Bool = false
    @State private var createEvent: Bool = false

    var body: some View {
        EventPermissionWrapperView { store in
            DayEventWrapperView(date: date, store: store) { _, events in
                ScrollView(.vertical) {
                    ZStack {
                        DecimalTimeMarkers()
                        EventuallyLayout(startOfDay: date.date, hourSlotHeight: siHourSlotHeight, config: .init(titleHeight: 40)) {
                            ForEach(events, id: \.calendarItemIdentifier) { event in
                                SingleEventBlobView(event: event)
                            }
                        }.padding(.leading, 40)
                    }
                    .padding(.vertical, 32)
                }
            }
            .sheet(isPresented: $createEvent) {
                NavigationView {
                    CreateEventView(store: store, date: date)
                        .interactiveDismissDisabled()
                }
            }
        }
        .navigationTitle(Text("\(date, format: .republicanDate.day(.preferred))"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    createEvent = true
                } label: {
                    Label("Nouvel évènement", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDetails = true
                } label: {
                    Label("Détails sur la date républicaine", systemImage: "info.circle")
                }
            }
        }
        .sheet(isPresented: $showDetails) {
            NavigationView {
                DateDetails(date: date)
            }.presentationDetents([.medium, .large])
        }
    }
}

struct SingleEventBlobView: View {
    let event: EKEvent
    @State private var tap: Bool = false

    var body: some View {
        Button {
            tap = true
        } label: {
            HStack(alignment: .top, spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(cgColor: event.calendar.cgColor))
                    .frame(width: 4)
                    .padding(.vertical, 4)
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.subheadline)
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
                        .font(.caption)
                }
            }
            .padding(4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(cgColor: event.calendar.cgColor).opacity(0.2))
            )
        }
        .buttonStyle(.plain)
        .eventuallyDateIntervalLayout(DateInterval(start: event.startDate, end: event.endDate))
        .sheet(isPresented: $tap) {
            NavigationView {
                EventDetailsView(event: event)
            }.presentationDetents([.medium, .large])
        }
    }
}

struct DecimalTimeMarkers: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<10) { hour in
                DecimalTimeMarker(hour: hour)
                    .padding(.bottom, decHourSlotHeight)
            }
            DecimalTimeMarker(hour: 0)
        }
    }
}

struct DecimalTimeMarker: View {
    var hour: Int

    var body: some View {
        HStack(spacing: 8) {
            Text("\(hour):00")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize()
                .frame(width: 32, alignment: .trailing)
            VStack {
                Divider()
            }.frame(maxWidth: .infinity)
        }.frame(height: 0)
    }
}
