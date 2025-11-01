//
//  DecimalTimeConverterWidget.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 30/05/2021.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct DecimalTimeConverterWidget: View {
    @EnvironmentObject var midnight: Midnight
    @State private var time = DecimalTime()
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "arrow.right.arrow.left")
            Text("Convertir")
            Spacer()
            Button {
                time = DecimalTime()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .accessibility(label: Text("Revenir à maintenant"))
                    .foregroundColor(.secondary)
                    .font(.body)
            }
        } content: {
            VStack(alignment: .leading) {
                Text("Temps SI")
                    .font(.headline)
                SITimePicker(time: $time)
                Divider()
                Text("Temps décimal")
                    .font(.headline)
                DecimalTimePicker(time: $time)
            }
        }
    }
}
