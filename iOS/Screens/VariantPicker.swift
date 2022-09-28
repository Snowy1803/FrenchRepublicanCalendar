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
