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
        VStack(alignment: .leading) {
            Text(today, format: .republicanDate.day(.preferred))
            Text(today, format: .republicanDate.year(.long))
            Spacer(minLength: 0)
            HStack {
                Spacer(minLength: 0)
                Text(entry.time.hourAndMinuteFormatted)
                    .font(.system(.largeTitle).monospacedDigit())
            }
            Spacer(minLength: 0)
            Text(today.isSansculottides ? today.weekdayName : today.dayName)
        }.foregroundColor(.primary)
    }
}

struct DateTimeWidget: Widget {
    let kind: String = "DateTimeWidget"
    
    var supported: [WidgetFamily] {
        return [.systemSmall]
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeProvider()) { entry in
            if #available(iOS 17.0, *) {
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
        DateTimeWidgetEntryView(entry: TimeEntry(date: Date(), time: DecimalTime(base: Date())))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
