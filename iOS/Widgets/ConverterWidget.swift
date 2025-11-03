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
            VStack(alignment: .leading) {
                Text("Date grégorienne")
                    .font(.headline)
                    .accessibility(hidden: true)
                DatePicker(selection: $from, in: FrenchRepublicanDate.origin..., displayedComponents: .date) {
                    Text("Date grégorienne")
                }.frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.locale, Locale(identifier: "fr"))
                .labelsHidden()
            }.padding(.top, 4)
            Divider()
            VStack(alignment: .leading) {
                Text("Date républicaine")
                    .font(.headline)
                RepublicanDatePicker(date: Binding(get: {
                    return MyRepublicanDateComponents(day: rep.components.day!, month: rep.components.month!, year: rep.components.year!)
                }, set: { cmps in
                    from = cmps.toRep.date
                }))
            }.padding(.top, 4)
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
//            CalendarMonthView(date: Binding {
//                FrenchRepublicanDate(date: from)
//            } set: {
//                from = $0.date
//            })
        }
    }
}
