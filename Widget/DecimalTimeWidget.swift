//
//  DecimalTimeWidget.swift
//  DateWidget
//
//  Created by Emil Pedersen on 28/09/2022.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
import WidgetKit

struct TimeProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimeEntry {
        let now = Date()
        let startOfDay = Calendar.gregorian.startOfDay(for: now)
        let current = DecimalTime(timeSinceMidnight: now.timeIntervalSince(startOfDay))
        return TimeEntry(date: now, time: current)
    }

    func getSnapshot(in context: Context, completion: @escaping (TimeEntry) -> ()) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimeEntry>) -> ()) {
        let now = Date()
        let startOfDay = Calendar.gregorian.startOfDay(for: now)
        var current = DecimalTime(timeSinceMidnight: now.timeIntervalSince(startOfDay))
        current.second = 0
        current.remainder = 0
        let dtime = current.decimalTime
        let day = dtime > 10_00_00
        current.decimalTime = day ? dtime - 10_00_00 : dtime
        var date = startOfDay + current.timeSinceMidnight
        if day {
            date = Calendar.gregorian.date(byAdding: .day, value: 1, to: date)!
        }
        current.second = 50 // avoids rounding errors
        
        var entries: [TimeEntry] = []
        for _ in 0..<100 {
            entries.append(TimeEntry(date: date, time: current))
            current.decimalTime += 100
            date += 100 * DecimalTime.decimalSecond
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TimeEntry: TimelineEntry {
    var date: Date
    var time: DecimalTime
}

struct TimeWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: TimeEntry

    var body: some View {
        Text(entry.time.hourAndMinuteFormatted)
            .fixedSize()
            .foregroundColor(.primary)
            .font(.system(.largeTitle).monospacedDigit())
            .scaledToFit()
            .padding()
    }
}

struct TimeWidget: Widget {
    let kind: String = "DecimalTimeWidget"
    
    var supported: [WidgetFamily] {
        if #available(iOS 16, *) {
            return [.systemSmall, .accessoryInline, .accessoryCircular]
        }
        return [.systemSmall]
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeProvider()) { entry in
            if #available(iOS 17.0, *) {
                TimeWidgetEntryView(entry: entry)
                    .containerBackground(.background, for: .widget)
            } else {
                TimeWidgetEntryView(entry: entry)
            }
        }
        .supportedFamilies(supported)
        .configurationDisplayName("Temps décimal")
        .description("Affiche l'heure en temps décimal")
    }
}

struct TimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        TimeWidgetEntryView(entry: TimeEntry(date: Date(), time: DecimalTime(base: Date())))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
