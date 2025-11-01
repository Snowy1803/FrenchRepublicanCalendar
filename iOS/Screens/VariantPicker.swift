//
//  VariantPicker.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 12/04/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
import StoreKit

struct VariantPicker: View {
    @EnvironmentObject var midnight: Midnight
    
    var body: some View {
        Form {
            ForEach(FrenchRepublicanDateOptions.Variant.allCases, id: \.rawValue) { variant in
                Section(
                    header: Text(FrenchRepublicanDate(date: Date(), options: .init(romanYear: FrenchRepublicanDateOptions.current.romanYear, variant: variant)).toLongString()),
                    footer: Text(variant.explanation)
                ) {
                    Button {
                        FrenchRepublicanDateOptions.current.variant = variant
                        midnight.objectWillChange.send()
                    } label: {
                        HStack {
                            Text(variant.name)
                                .foregroundColor(.primary)
                            if FrenchRepublicanDateOptions.current.variant == variant {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Toggle(isOn: Binding {
                FrenchRepublicanDateOptions.current.romanYear
            } set: {
                FrenchRepublicanDateOptions.current.romanYear = $0
                midnight.objectWillChange.send()
            }) {
                Text("Chiffres romains pour les années")
            }
            
            Section(
                header: Text("Fuseau horaire"),
                footer: Text("Ce fuseau horaire sera utilisé pour le Temps Décimal, mais aussi pour déterminer la date du jour.")
            ) {
                TimeZonePicker()
            }
        }.navigationBarTitle(Text("Variantes"))
        .listNotTooWide()
        .onDisappear {
            let key = "store-review-settings-count"
            let count = UserDefaults.standard.integer(forKey: key) + 1
            UserDefaults.standard.set(count, forKey: key)
            if count % 30 == 2 { // second time it disappears
                SKStoreReviewController.requestReview()
            }
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
            midnight.objectWillChange.send()
        }) {
            VStack(alignment: .leading) {
                Text("Fuseau horaire local")
                Text("Utiliser l'heure système (\(timeZoneName(tz: TimeZone.current)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }.tag(nil as TimeZone?)
            VStack(alignment: .leading) {
                Text("Heure de l'Observatoire de Paris")
                Text("Utiliser l'heure utilisée en France avant 1911 (\(timeZoneName(tz: TimeZone.parisMeridian)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }.tag(TimeZone.parisMeridian)
            let paris = TimeZone(identifier: "Europe/Paris")!
            VStack(alignment: .leading) {
                Text("Heure à Paris")
                Text("Utiliser l'heure actuelle en France (\(timeZoneName(tz: paris)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }.tag(paris)
            // Could add an "Other..." option
        }
        .pickerStyle(.inline)
        .labelsHidden()

    }
}

extension FrenchRepublicanDateOptions.Variant {
    
    var name: String {
        switch self {
        case .original:
            return "Calendrier originel"
        case .romme:
            return "Réforme de Romme"
        }
    }
    
    var explanation: String {
        switch self {
        case .original:
            return "Version originelle, utilisée entre l'an \(FrenchRepublicanDate(dayInYear: 1, year: 2).formattedYear) et l'an \(FrenchRepublicanDate(dayInYear: 1, year: 16).formattedYear), ainsi que pendant la commune de Paris.\nLa première année sextile est l'an \(FrenchRepublicanDate(dayInYear: 1, year: 3).formattedYear), il y a ensuite une année sextile tous les 4 ans."
        case .romme:
            return "Version réformée, n'ayant jamais réellement été utilisée. Le décalage des jours sur le long terme y a été corrigé : les années divisibles par 4 sont sextiles, sauf celles divisibles par 100, sauf celles divisibles par 400, sauf celles divisibles par 4000."
        }
    }
}
