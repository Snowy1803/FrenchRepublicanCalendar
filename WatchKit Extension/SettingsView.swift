//
//  SettingsView.swift
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

struct SettingsView: View {
    @EnvironmentObject var midnight: Midnight
    
    func caption(variant: FrenchRepublicanDateOptions.Variant) -> Text {
        Text(FrenchRepublicanDate(date: Date(), options: {
            var options = FrenchRepublicanDateOptions.current
            options.variant = variant
            return options
        }()), format: .republicanDate.day().year())
    }
    
    var body: some View {
        Form {
            Picker(selection: Binding {
                FrenchRepublicanDateOptions.current.variant
            } set: {
                FrenchRepublicanDateOptions.current.variant = $0
            }) {
                PickerContentCaptioned(
                    label: Text("Modèle Delambre"),
                    caption: caption(variant: .delambre)
                ).tag(FrenchRepublicanDateOptions.Variant.delambre)
                PickerContentCaptioned(
                    label: Text("Réforme de Romme"),
                    caption: caption(variant: .romme)
                ).tag(FrenchRepublicanDateOptions.Variant.romme)
                PickerContentCaptioned(
                    label: Text("Article X original"),
                    caption: caption(variant: .original)
                ).tag(FrenchRepublicanDateOptions.Variant.original)
            } label: {
                Text("Variante")
            }
            
            Toggle(isOn: Binding {
                FrenchRepublicanDateOptions.current.romanYear
            } set: {
                FrenchRepublicanDateOptions.current.romanYear = $0
            }) {
                Text("Chiffres romains pour les années")
            }
            
            Section(
                header: Text("Fuseau horaire"),
                footer: Text("Ce fuseau horaire sera utilisé pour le Temps Décimal, mais aussi pour déterminer la date du jour.")
            ) {
                TimeZonePicker()
            }
        }.pickerStyle(.inline)
    }
}

#Preview {
    SettingsView()
}
