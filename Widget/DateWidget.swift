//
//  DateWidget.swift
//  DateWidget
//
//  Created by Emil Pedersen on 21/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let currentDate = Calendar.gregorian.startOfDay(for: Date())
        for offset in 0..<100 {
            let entryDate = Calendar.gregorian.date(byAdding: .day, value: offset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct DateWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        let today = FrenchRepublicanDate(date: entry.date)
        Group {
            if family == WidgetFamily.systemSmall {
                VStack(alignment: .leading) {
                    SimpleDateStack(today: today)
                    Spacer()
                    HStack {
                        Spacer()
                        Text(today.dayName)
                    }
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Text(today.weekdayName)
                        Spacer()
                        Text(today.dayName)
                    }
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Spacer()
                            SimpleDateStack(today: today)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Spacer()
                            Text(today.quarter)
                            Text("Décade \(today.components.weekOfYear!)/37")
                            Text("Jour \(today.dayInYear)/\(today.isYearSextil ? 366 : 365)")
                        }
                    }
                }
            }
        }
        .foregroundColor(.primary)
        .padding()
    }
}

struct SimpleDateStack: View {
    var today: FrenchRepublicanDate

    var body: some View {
        Text(String(today.components.day!))
            .font(.system(size: 50))
        Text(today.monthName)
        Text("An \(today.formattedYear)")
    }
}

@main
struct DateWidget: Widget {
    let kind: String = "DateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DateWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Aujourd'hui")
        .description("Affiche la date actuelle dans le Calendrier Républicain")
    }
}

struct DateWidget_Previews: PreviewProvider {
    static var previews: some View {
        DateWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
