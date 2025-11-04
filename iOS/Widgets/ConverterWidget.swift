//
//  ConverterWidget.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct ConverterWidget: View {
    @EnvironmentObject var midnight: Midnight
    @State private var from = Date()
    @State private var showPicker: Bool? = nil
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "arrow.right.arrow.left")
            Text("Convertir")
            Spacer()
            if from.iso != Date().iso {
                Button {
                    from = Date()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .accessibility(label: Text("Revenir à aujourd'hui"))
                        .foregroundColor(.secondary)
                        .font(.body)
                }
            }
        } content: {
            let rep = FrenchRepublicanDate(date: from)
            FoldableDatePicker(
                si: true,
                label: Text("Date grégorienne"),
                date: $from,
                showPicker: Binding {
                    showPicker == true
                } set: { newValue in
                    showPicker = newValue ? true : nil
                }
            )
            Divider()
            FoldableDatePicker(
                si: false,
                label: Text("Date républicaine"),
                date: $from,
                showPicker: Binding {
                    showPicker == false
                } set: { newValue in
                    showPicker = newValue ? false : nil
                }
            )
            Divider()
            NavigationLink(destination: DateDetails(date: rep)) {
                HStack {
                    Image.decorative(systemName: "calendar")
                        .frame(width: 25)
                    Text("Détails")
                    Spacer()
                    Image.decorative(systemName: "chevron.right")
                        .imageScale(.small)
                        .foregroundColor(.secondary)
                }.foregroundColor(.primary)
            }.padding(.top, 4)
//            Divider()
//            WheelRepublicanDatePicker(precision: .republicanDate.day(.monthOnly).year(), selection: Binding {
//                FrenchRepublicanDate(date: from)
//            } set: {
//                from = $0.date
//            })
        }
    }
}
