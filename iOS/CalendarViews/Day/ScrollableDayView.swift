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
    @EnvironmentObject var store: EventStore
    @EnvironmentObject var midnight: Midnight
    @Binding var date: FrenchRepublicanDate
    @State private var showDetails: Bool = false
    @State private var showCalendars: Bool = false
    @State private var createEvent: Bool = false

    var body: some View {
        EventPermissionWrapperView {
            DayEventWrapperView(date: date) { _, events in
                ScrollView(.vertical) {
                    ZStack {
                        DecimalTimeMarkers()
                        EventuallyLayout(startOfDay: date.date, hourSlotHeight: siHourSlotHeight, config: .init(titleHeight: 40)) {
                            ForEach(events) { event in
                                if let calendar = event.calendar, store.shouldShow(calendar: calendar) {
                                    SingleEventBlobView(event: event)
                                }
                            }
                        }.padding(.leading, 48)
                        if Calendar.gregorian.isDate(date.date, inSameDayAs: Date()) {
                            DecimalTimeTodayMarker()
                        }
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
        .topSafeAreaBar {
            ScrollableWeekView(selection: $date)
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
                    showCalendars = true
                } label: {
                    Label("Calendriers", systemImage: "calendar")
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
        .sheet(isPresented: $showCalendars) {
            NavigationView {
                CalendarFilterView()
                    .navigationTitle("Calendriers")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        if #available(iOS 26.0, *) {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(role: .close) {
                                    showCalendars = false
                                }
                            }
                        } else {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("OK") {
                                    showCalendars = false
                                }
                            }
                        }
                    }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func topSafeAreaBar(@ViewBuilder content: () -> some View) -> some View {
        self.safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                content()
                    .padding(.vertical, 8)
                Divider()
            }
            .background(Material.bar)
        }
    }
}

struct SingleEventBlobView: View {
    let event: EventModel
    @State private var tap: Bool = false

    var body: some View {
        Button {
            tap = true
        } label: {
            HStack(alignment: .top, spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(cgColor: event.calendar!.cgColor))
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
                    .fill(Color(cgColor: event.calendar!.cgColor).opacity(0.2))
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
                .frame(width: 40, alignment: .trailing)
            VStack {
                Divider()
            }.frame(maxWidth: .infinity)
        }.frame(height: 0)
    }
}

struct DecimalTimeTodayMarker: View {
    @State private var progress: CGFloat = DecimalTime().decimalTime / 100000
    let timer = Timer.publish(every: DecimalTime.decimalSecond, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 0) {
            Text("\(DecimalTime(base: Date()), format: .decimalTime.hour().minute())")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .fixedSize()
                .padding(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4))
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.accentColor))
                .frame(width: 40, alignment: .trailing)
            Rectangle()
                .fill(Color.accentColor)
                .frame(height: 2)
                .frame(maxWidth: .infinity)
        }.frame(height: 0)
        .padding(.top, decHourSlotHeight * 10 * progress)
        .padding(.bottom, decHourSlotHeight * 10 * (1 - progress))
        .onReceive(timer) { _ in
            self.progress = DecimalTime().decimalTime / 100000
        }
    }
}
