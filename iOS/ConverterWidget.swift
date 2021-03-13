//
//  ConverterWidget.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

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
            DatePicker(selection: $from, in: FrenchRepublicanDate.origin..., displayedComponents: .date) {
                Text("Date grégorienne : ")
            }.environment(\.locale, Locale(identifier: "fr"))
            Divider()
            HStack {
                Text("Date républicaine : ")
                Spacer()
                RepublicanDatePicker(date: Binding(get: {
                    return MyRepublicanDateComponents(day: rep.components.day!, month: rep.components.month!, year: rep.components.year!)
                }, set: { cmps in
                    from = cmps.toRep.date
                }))
            }
            Divider()
            NavigationLink(destination: DateDetails(date: rep)) {
                HStack {
                    Text(rep.toLongString())
                    Spacer()
                    Image.decorative(systemName: "chevron.right")
                }
            }.padding(.top, 5)
        }
    }
}
