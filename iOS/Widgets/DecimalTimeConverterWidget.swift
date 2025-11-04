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
    @State private var showPicker: Bool? = nil
    
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
            VStack {
                FoldableDecimalTimePicker(
                    si: true,
                    text: Text("Temps SI"),
                    precision: .decimalTime.hour().minute().second(),
                    decimalTime: $time,
                    showPicker: Binding {
                        showPicker == true
                    } set: { newValue in
                        showPicker = newValue ? true : nil
                    }
                )
                Divider()
                FoldableDecimalTimePicker(
                    si: false,
                    text: Text("Temps décimal"),
                    precision: .decimalTime.hour().minute().second(),
                    decimalTime: $time,
                    showPicker: Binding {
                        showPicker == false
                    } set: { newValue in
                        showPicker = newValue ? false : nil
                    }
                )
            }.padding(.bottom, -10)
        }
    }
}
