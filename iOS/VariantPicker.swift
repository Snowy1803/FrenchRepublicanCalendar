//
//  VariantPicker.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 12/04/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import SwiftUI
import FrenchRepublicanCalendarCore

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
        }.navigationBarTitle(Text("Variantes"))
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
            return "Version originelle, utilisée entre l'an \(FrenchRepublicanDate(dayInYear: 1, year: 2).formattedYear) et l'an \(FrenchRepublicanDate(dayInYear: 1, year: 16).formattedYear), ainsi que pendant la commune de Paris.\nLa première année sextile est l'an \(FrenchRepublicanDate(dayInYear: 1, year: 3).formattedYear), puis il y a une nouvelle année sextile tous les 4 ans."
        case .romme:
            return "Version réformée, n'ayant jamais réellement été utilisée. Le décalage des années sextile sur le long terme y a été corrigé : les années divisibles par 4 sont sextiles, sauf celles divisibles par 100, sauf celles divisibles par 400, sauf celles divisibles par 4000."
        }
    }
}
