//
//  TimeZonePicker.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 26/11/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct PickerContentCaptioned: View {
    var label: Text
    var caption: Text
    var body: some View {
        VStack(alignment: .leading) {
            label
            caption
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct TimeZonePicker: View {
    @EnvironmentObject var midnight: Midnight
    
    func timeZoneName(tz: TimeZone) -> String {
        var formatter = Date.FormatStyle.dateTime.timeZone(.localizedGMT(.long))
        formatter.locale = Locale(identifier: "fr-FR")
        formatter.timeZone = tz
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.calendar.timeZone = tz
        formatter.calendar.locale = formatter.locale
        return formatter.format(Date())
    }
    
    var body: some View {
        Picker("Fuseau horaire", selection: Binding {
            FrenchRepublicanDateOptions.current.timeZone
        } set: {
            FrenchRepublicanDateOptions.current.timeZone = $0
        }) {
            PickerContentCaptioned(
                label: Text("Heure locale"),
                caption: Text("Utiliser le fuseau horaire système (\(timeZoneName(tz: TimeZone.current)))")
            ).tag(nil as TimeZone?)
            PickerContentCaptioned(
                label: Text("Heure moyenne de Paris"),
                caption: Text("Fuseau utilisé en France entre 1891 et 1911 (\(timeZoneName(tz: TimeZone.parisMeridian)))")
            ).tag(TimeZone.parisMeridian)
            let gmt = TimeZone(identifier: "GMT")!
            PickerContentCaptioned(
                label: Text("Heure de Greenwich"),
                caption: Text("Fuseau utilisé en France entre 1911 et 1940 (\(timeZoneName(tz: gmt)))")
            ).tag(gmt)
            let paris = TimeZone(identifier: "Europe/Paris")!
            PickerContentCaptioned(
                label: Text("Heure à Paris"),
                caption: Text("Fuseau utilisé en France actuellement (\(timeZoneName(tz: paris)))")
            ).tag(paris)
            // Could add an "Other..." option
        }
        .pickerStyle(.inline)
        .labelsHidden()
    }
}
