//
//  VariantPicker.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 19/11/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import FrenchRepublicanCalendarCore
import SwiftUI

struct VariantPicker: View {
    // True: WhatsNew view
    // False: Settings view
    var firstShown: Bool

    var body: some View {
        Form {
            VariantLink(
                firstShown: firstShown,
                variant: .delambre,
                icon: "sun.and.horizon.fill",
                text: Text("Version originelle, utilisée entre l'an \(FrenchRepublicanDate(dayInYear: 1, year: 2).formattedYear) et l'an \(FrenchRepublicanDate(dayInYear: 1, year: 16).formattedYear), ainsi que pendant la commune de Paris. Basé sur l'astronomie.")
            )
            VariantLink(
                firstShown: firstShown,
                variant: .romme,
                icon: "doc.badge.plus",
                text: Text("Version réformée, n'ayant jamais réellement été utilisée. Change la règle sur les années sextiles pour avoir une règle similaire au calendrier grégorien.")
            )
            VariantLink(
                firstShown: firstShown,
                variant: .original,
                icon: "doc.text",
                text: Text("Version originelle, mais privilégiant l'article X sur l'article III: il y a une année sextile tous les 4 ans.\nCe calendrier se décale sur le temps, et n'est donc pas recommandé.")
            )
        }.navigationTitle(Text("Variantes"))
    }
}

struct VariantLink: View {
    var firstShown: Bool
    var variant: FrenchRepublicanDateOptions.Variant
    var icon: String
    var text: Text
    
    @EnvironmentObject var midnight: Midnight
    
    @ViewBuilder var labels: some View {
        let baseLabels = Group {
            if variant == .delambre {
                TagLabel(text: "Recommandé", color: .green)
            }
            if variant == .original {
                TagLabel(text: "Déconseillé", color: .red)
            }
            if variant == .romme || variant == .original {
                TagLabel(text: "Infini", color: .blue)
            }
        }
        let extraLabel = Group {
            if firstShown && variant == FrenchRepublicanDateOptions.current.variant && variant != .delambre {
                // Only shown in WhatsNew during migration to 7.x
                TagLabel(text: "Sélectionné avant la MàJ", color: .gray)
            }
        }
        if #available(iOS 16.0, *) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    baseLabels
                    extraLabel
                }
                VStack(alignment: .leading) {
                    HStack {
                        baseLabels
                    }
                    extraLabel
                }
            }
        } else {
            VStack(alignment: .leading) {
                HStack {
                    baseLabels
                }
                extraLabel
            }
        }

    }

    var body: some View {
        Section {
            NavigationLink(destination: VariantDetails(variant: variant)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 16) {
                        Image(systemName: icon)
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.accentColor)
                            .font(.largeTitle.weight(.semibold))
                            .frame(width: 60)
                        VStack(alignment: .leading) {
                            Text(variant.name).font(.headline)
                            Text(FrenchRepublicanDate(date: Date(), options: {
                                var options = FrenchRepublicanDateOptions.current
                                options.variant = variant
                                return options
                            }()), format: .republicanDate.day().year())
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            labels
                        }
                        if !firstShown {
                            Spacer(minLength: 0)
                            Image(systemName: variant == FrenchRepublicanDateOptions.current.variant ? "checkmark.circle.fill" : "circle")
                                .padding(.vertical)
                                .foregroundStyle(.tint)
                                .font(.title)
                                .onTapGesture {
                                    FrenchRepublicanDateOptions.current.variant = variant
                                    midnight.objectWillChange.send()
                                }
                        }
                    }
                    text.font(.body)
                }
                .multilineTextAlignment(.leading)
                .foregroundStyle(.primary)
            }.buttonStyle(.plain)
        }
    }
}

struct TagLabel: View {
    var text: LocalizedStringKey
    var color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Capsule().fill(color))
    }
}

struct VariantDetails: View {
    @EnvironmentObject var midnight: Midnight
    @AppStorage("frc-last-open-build", store: UserDefaults.shared) var lastVersion = 0
    var variant: FrenchRepublicanDateOptions.Variant

    var body: some View {
        Text("TODO")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    FrenchRepublicanDateOptions.current.variant = variant
                    midnight.objectWillChange.send()
                    lastVersion = WhatsNew.currentVersion
                } label: {
                    if #available(iOS 26.0, *) {
                        Text("Sélectionner")
                            .font(.headline)
                    } else {
                        Text("Sélectionner")
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
}

#Preview {
    NavigationView {
        VariantPicker(firstShown: true)
    }
}
