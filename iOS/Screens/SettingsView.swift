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
    /// This is separated to avoid GitHub scrapers. If you are looking for email addresses, please disregard this one.
    static let personalWebsite = "emil.codes"
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
            
            Section(header: Text("Légal"), footer: Text("Nous ne traitons pas vos données personnelles. Vos données restent en sécurité sur votre appareil.")) {
                NavigationLink {
                    Form {
                        Link("swiftui-introspect", destination: URL(string: "https://github.com/siteline/swiftui-introspect/blob/main/LICENSE")!)
                    }.navigationTitle(Text("Licenses open source"))
                } label: {
                    Text("Licenses open source")
                }
                NavigationLink {
                    Form {
                        Section(footer: Text("L'application est entièrement open source. Développée en intégralité par Emil Pedersen")) {
                            Link("Code source de l'application", destination: URL(string: "https://github.com/Snowy1803/FrenchRepublicanCalendar")!)
                            Link("Code source du convertisseur", destination: URL(string: "https://github.com/Snowy1803/FrenchRepublicanCalendarCore")!)
                        }
                        Section(header: Text("Sources astronomiques pour le modèle Delambre"), footer: Text("P. ROCHER, © INSTITUT DE MÉCANIQUE CÉLESTE ET DE CALCUL DES ÉPHÉMÉRIDES – OBSERVATOIRE DE PARIS")) {
                            Link("Équinoxe d'automne de 1583 à 2999", destination: URL(string: "https://www.imcce.fr/newsletter/docs/Equinoxe_automne_1583_2999.pdf")!)
                        }
                    }.navigationTitle(Text("Crédits"))
                } label: {
                    Text("Crédits")
                }
                Link("Rapporter un problème", destination: URL(string: "https://github.com/Snowy1803/FrenchRepublicanCalendar/issues/new")!)
                Link("Nous contacter", destination: URL(string: "mailto:frc@\(Self.personalWebsite)?subject=Application Calendrier Républicain")!)
            }
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
