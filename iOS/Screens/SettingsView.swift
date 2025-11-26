//
//  SettingsView.swift
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

struct SettingsView: View {
    @EnvironmentObject var midnight: Midnight
    
    var body: some View {
        Form {
            NavigationLink(destination: VariantPicker(firstShown: false)) {
                HStack {
                    Text("Variante")
                    Spacer()
                    Text(FrenchRepublicanDateOptions.current.variant.name)
                        .foregroundStyle(.secondary)
                }
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
            
            #if DEBUG
            Button {
                UserDefaults.shared.set(0, forKey: "frc-last-open-build")
            } label: {
                Text("Afficher l'écran de bienvenue")
            }
            #endif
        }.navigationBarTitle(Text("Réglages"))
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

extension FrenchRepublicanDateOptions.Variant {
    var name: String {
        switch self {
        case .romme:
            return "Réforme de Romme"
        case .delambre:
            return "Modèle Delambre"
        case .original:
            return "Article X original"
        }
    }
}
