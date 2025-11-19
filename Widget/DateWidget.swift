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
        for offset in 0..<30 {
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
            if #available(iOSApplicationExtension 16, *), family == .accessoryInline {
                ViewThatFits(in: .horizontal) {
                    Text(today.toVeryLongString())
                    Text(today.toLongString())
                    Text(today.toLongStringNoYear())
                    Text(today.toShortString())
                }
            } else if #available(iOSApplicationExtension 16, *), family == .accessoryRectangular {
                HStack {
                    VStack(alignment: .leading) {
                        Text(today, format: .republicanDate.day(.preferred))
                        Text(today, format: .republicanDate.year(.long))
                        Text(today.isSansculottides ? today.weekdayName : today.dayName)
                    }
                    Spacer(minLength: 0)
                }
            } else if family == .systemSmall {
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
                            Text("Jour \(today.dayInYear)/\(today.dayCountThisYear)")
                        }
                    }
                }
            }
        }
        .foregroundColor(.primary)
    }
}

struct SimpleDateStack: View {
    var today: FrenchRepublicanDate

    var body: some View {
        Text(String(today.components.day!))
            .font(.system(size: 50))
        Text(today.monthName)
        Text(today, format: .republicanDate.year(.long))
    }
}

struct DateWidget: Widget {
    let kind: String = "DateWidget"
    
    var supported: [WidgetFamily] {
        if #available(iOS 16, *) {
            return [.systemSmall, .systemMedium, .accessoryInline, .accessoryRectangular]
        }
        return [.systemSmall, .systemMedium]
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DateWidgetEntryView(entry: entry)
                    .containerBackground(.background, for: .widget)
            } else {
                DateWidgetEntryView(entry: entry)
            }
        }
        .supportedFamilies(supported)
        .configurationDisplayName("Aujourd'hui")
        .description("Affiche la date actuelle dans le Calendrier Républicain")
    }
}

@main
struct FrenchRepublicanWidgets: WidgetBundle {
    var body: some Widget {
        DateWidget()
        TimeWidget()
        DateTimeWidget()
    }
}

struct DateWidget_Previews: PreviewProvider {
    static var previews: some View {
        DateWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
