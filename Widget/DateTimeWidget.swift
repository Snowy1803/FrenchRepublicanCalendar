//
//  DateTimeWidget.swift
//  DateWidget
//
//  Created by Emil Pedersen on 02/11/2025.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
import WidgetKit

struct DateTimeWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: TimeEntry

    var body: some View {
        let today = FrenchRepublicanDate(date: entry.date)
        switch family {
        case .accessoryInline:
            if #available(iOS 16, *) {
                ViewThatFits(in: .horizontal) {
                    Text("\(today, format: .republicanDate.day().year()), \(entry.time, format: .decimalTime.hour().minute())")
                    Text("\(today, format: .republicanDate.day()) à \(entry.time, format: .decimalTime.hour().minute())")
                    Text("\(today, format: .republicanDate.day().dayLength(.short)), \(entry.time, format: .decimalTime.hour().minute())")
                }
                .monospacedDigit()
            }
        case .accessoryRectangular:
            if #available(iOS 16, *) {
                HStack {
                    VStack(alignment: .leading) {
                        ViewThatFits(in: .horizontal) {
                            Text(today, format: .republicanDate.day(.preferred).year(today.isSansculottides ? .none : .long))
                            Text(today, format: .republicanDate.day(.preferred))
                        }
                        .font(.headline)
                        .widgetAccentable()
                        Text(today, format: today.isSansculottides ? .republicanDate.year() : .republicanDate.day(.dayName))
                            .foregroundStyle(.secondary)
                        Text(entry.time, format: .decimalTime.hour().minute())
                            .monospacedDigit()
                    }
                    Spacer(minLength: 0)
                }
            }
        default: // systemSmall
            VStack(alignment: .leading) {
                Text(today, format: .republicanDate.day(.preferred))
                Text(today, format: .republicanDate.year(.long))
                Spacer(minLength: 0)
                HStack {
                    Spacer(minLength: 0)
                    Text(entry.time, format: .decimalTime.hour().minute())
                        .font(.system(.largeTitle).monospacedDigit())
                }
                Spacer(minLength: 0)
                Text(today.isSansculottides ? today.weekdayName : today.dayName)
            }.foregroundColor(.primary)
        }
    }
}

struct DateTimeWidget: Widget {
    let kind: String = "DateTimeWidget"
    
    var supported: [WidgetFamily] {
        #if os(watchOS)
        return [.accessoryInline, .accessoryRectangular]
        #else
        if #available(iOS 16, *) {
            return [.systemSmall, .accessoryInline, .accessoryRectangular]
        }
        return [.systemSmall]
        #endif
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeProvider()) { entry in
            if #available(iOS 17.0, watchOS 10.0, *) {
                DateTimeWidgetEntryView(entry: entry)
                    .containerBackground(.background, for: .widget)
            } else {
                DateTimeWidgetEntryView(entry: entry)
            }
        }
        .supportedFamilies(supported)
        .configurationDisplayName("Date et Heure")
        .description("Affiche la date républicaine et l'heure décimale")
    }
}

struct DateTimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        #if os(watchOS)
        DateTimeWidgetEntryView(entry: TimeEntry(date: Date(), time: DecimalTime(base: Date())))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        #else
        DateTimeWidgetEntryView(entry: TimeEntry(date: Date(), time: DecimalTime(base: Date())))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        #endif
    }
}
