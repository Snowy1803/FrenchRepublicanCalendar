//
//  VariantExplanation.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 04/12/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import FrenchRepublicanCalendarCore
import SwiftUI

struct VariantExplanation: View {
    var variant: FrenchRepublicanDateOptions.Variant

    var body: some View {
        Text("TODO")
            .navigationTitle(variant.name)
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
