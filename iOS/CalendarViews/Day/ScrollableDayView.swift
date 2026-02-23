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
    #if os(watchOS)
    30
    #else
    50
    #endif
}

fileprivate var decHourSlotHeight: CGFloat {
    siHourSlotHeight * 24 / 10
}

struct ScrollableDayView: View {
    @EnvironmentObject var store: EventStore
    @EnvironmentObject var midnight: Midnight
    #if os(watchOS)
    var date: FrenchRepublicanDate
    #else
    @Binding var date: FrenchRepublicanDate
    #endif
    @State private var showDetails: Bool = false
    #if !os(watchOS)
    @State private var showCalendars: Bool = false
    @State private var createEvent: Bool = false
    #endif

    var body: some View {
        EventPermissionWrapperView {
            DayEventWrapperView(date: date) { _, events in
                ScrollView(.vertical) {
                    ZStack {
                        DecimalTimeMarkers()
                        EventuallyLayout(startOfDay: date.date, hourSlotHeight: siHourSlotHeight, config: .init(titleHeight: titleHeight)) {
                            ForEach(events) { event in
                                if let calendar = event.calendar, store.shouldShow(calendar: calendar) {
                                    SingleEventBlobView(event: event)
                                }
                            }
                        }.padding(.leading, leadingPadding)
                        if Calendar.gregorian.isDate(date.date, inSameDayAs: Date()) {
                            DecimalTimeTodayMarker()
                        }
                    }
                    .padding(.vertical, verticalPadding)
                }
            }
            #if !os(watchOS)
            .sheet(isPresented: $createEvent) {
                NavigationView {
                    CreateEventView(store: store, date: date)
                        .interactiveDismissDisabled()
                }
            }
            #endif
        }
        #if os(watchOS)
        .navigationTitle(Text("\(date, format: .republicanDate.day(.preferred))"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    showDetails = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .sheet(isPresented: $showDetails) {
            DateDetails(components: date.toMyDateComponents, date: date)
        }
        #else
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
        #endif
    }
    
    private var titleHeight: CGFloat {
        #if os(watchOS)
        24
        #else
        40
        #endif
    }
    
    private var leadingPadding: CGFloat {
        #if os(watchOS)
        28
        #else
        48
        #endif
    }
    
    private var verticalPadding: CGFloat {
        #if os(watchOS)
        16
        #else
        32
        #endif
    }
}

#if !os(watchOS)
extension View {
    @ViewBuilder
    func topSafeAreaBar(@ViewBuilder content: () -> some View) -> some View {
        VStack {
            Spacer(minLength: 0)
            self
            Spacer(minLength: 0)
        }.safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                content()
                    .padding(.vertical, 8)
                Divider()
            }
            .background(Material.bar)
        }
    }
}
#endif

struct SingleEventBlobView: View {
    let event: EventModel
    #if !os(watchOS)
    @State private var tap: Bool = false
    #endif

    var body: some View {
        #if os(watchOS)
        NavigationLink {
            EventDetailsView(event: event)
        } label: {
            eventContent
        }
        .buttonStyle(.plain)
        .eventuallyDateIntervalLayout(DateInterval(start: event.startDate, end: event.endDate))
        #else
        Button {
            tap = true
        } label: {
            eventContent
        }
        .buttonStyle(.plain)
        .eventuallyDateIntervalLayout(DateInterval(start: event.startDate, end: event.endDate))
        .sheet(isPresented: $tap) {
            NavigationView {
                EventDetailsView(event: event)
            }.presentationDetents([.medium, .large])
        }
        #endif
    }
    
    private var eventContent: some View {
        HStack(alignment: .top, spacing: blobSpacing) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(cgColor: event.calendar!.cgColor))
                .frame(width: blobBarWidth)
                .padding(.vertical, 4)
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(titleFont)
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
        .padding(blobPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: blobCornerRadius)
                .fill(Color(cgColor: event.calendar!.cgColor).opacity(0.2))
        )
    }
    
    private var blobSpacing: CGFloat {
        #if os(watchOS)
        2
        #else
        4
        #endif
    }
    
    private var blobBarWidth: CGFloat {
        #if os(watchOS)
        3
        #else
        4
        #endif
    }
    
    private var blobPadding: CGFloat {
        #if os(watchOS)
        2
        #else
        4
        #endif
    }
    
    private var blobCornerRadius: CGFloat {
        #if os(watchOS)
        6
        #else
        10
        #endif
    }
    
    private var titleFont: Font {
        #if os(watchOS)
        .caption2
        #else
        .subheadline
        #endif
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
        HStack(spacing: markerSpacing) {
            Text(markerText)
                .font(markerFont)
                .foregroundStyle(.secondary)
                .fixedSize()
                .frame(width: markerWidth, alignment: .trailing)
            VStack {
                Divider()
            }.frame(maxWidth: .infinity)
        }.frame(height: 0)
    }
    
    private var markerText: String {
        #if os(watchOS)
        "\(hour)"
        #else
        "\(hour):00"
        #endif
    }
    
    private var markerFont: Font {
        #if os(watchOS)
        .system(size: 10)
        #else
        .caption
        #endif
    }
    
    private var markerWidth: CGFloat {
        #if os(watchOS)
        24
        #else
        40
        #endif
    }
    
    private var markerSpacing: CGFloat {
        #if os(watchOS)
        4
        #else
        8
        #endif
    }
}

struct DecimalTimeTodayMarker: View {
    @State private var progress: CGFloat = DecimalTime().decimalTime / 100000
    let timer = Timer.publish(every: DecimalTime.decimalSecond, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 0) {
            #if os(watchOS)
            Circle()
                .fill(Color.accentColor)
                .frame(width: 6, height: 6)
                .frame(width: 24, alignment: .trailing)
            #else
            Text("\(DecimalTime(base: Date()), format: .decimalTime.hour().minute())")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .fixedSize()
                .padding(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4))
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.accentColor))
                .frame(width: 40, alignment: .trailing)
            #endif
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
