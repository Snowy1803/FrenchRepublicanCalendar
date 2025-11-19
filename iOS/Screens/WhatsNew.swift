//
//  WhatsNew.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 19/11/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

struct WhatsNew: View {
    @AppStorage("frc-last-open-build", store: UserDefaults.shared) var lastVersion = 0
    static let lastSignificantChange = 25 // build number for 7.0
    static var currentVersion: Int {
        Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0") ?? 0
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    WhatsNewRow(
                        icon: "figure.wave",
                        title: Text("Bienvenue dans votre calendrier républicain"),
                        text: Text("Explorez une version moderne du Calendrier Républicain : intuitive, élégante et complète")
                    )
                    WhatsNewRow(
                        icon: "sun.and.horizon.fill",
                        title: Text("Choisissez votre variante"),
                        text: Text("Sélectionnez entre le modèle Delambre ou la réforme de Romme")
                    )
                    WhatsNewRow(
                        icon: "calendar",
                        title: Text("Calendrier complet"),
                        text: Text("Remontez les années et voyez tous vos évènements de calendrier, dans le calendrier républicain")
                    )
                    WhatsNewRow(
                        icon: "clock.arrow.circlepath",
                        title: Text("Temps décimal"),
                        text: Text("Consultez l'heure dans un format d'un autre temps, désormais aussi dans les anciens fuseaux horaires de France")
                    )
                    WhatsNewRow(
                        icon: "arrow.right.arrow.left",
                        title: Text("Convertir"),
                        text: Text("Convertissez toutes les dates à partir de l'An I, entre les calendriers Grégorien et Républicain")
                    )
                    WhatsNewRow(
                        icon: {
                            if #available(iOS 18.0, *) {
                                "widget.small"
                            } else {
                                "square.text.square"
                            }
                        }(),
                        title: Text("Widgets"),
                        text: Text("Ajoutez des widgets à votre écran d'accueil ou de verrouillage, pour toujours voir la date républicaine et/ou l'heure décimale")
                    )
                    WhatsNewRow(
                        icon: "waveform.and.mic",
                        title: Text("Demandez à Siri"),
                        text: Text("Ajoutez des commandes à Siri pour consulter la date républicaine ou l'heure décimale")
                    )
                }.padding(32)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        lastVersion = WhatsNew.currentVersion
                    } label: {
                        if #available(iOS 26.0, *) {
                            Text("Continuer")
                                .font(.headline)
                        } else {
                            Text("Continuer")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .prominentButtonStyle()
                }
            }
        }
        .navigationTitle(Text("Bienvenue"))
        .notTooWide()
    }
}

struct WhatsNewRow: View {
    var icon: String
    var title: Text
    var text: Text
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .imageScale(.large)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.accentColor)
                .font(.largeTitle.weight(.semibold))
                .frame(width: 60)
            VStack(alignment: .leading) {
                title.font(.headline)
                text.font(.body)
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    NavigationView {
        WhatsNew()
    }
}
