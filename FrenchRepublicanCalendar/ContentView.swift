//
//  ContentView.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TodayWidget()
                    ConverterWidget()
                }
            }.navigationBarTitle("Calendrier Républicain")
        }
    }
}

struct TodayWidget: View {
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "calendar")
            Text("Aujourd'hui")
            Spacer()
        } content: {
            let today = FrenchRepublicanDate(date: Date())
            NavigationLink(destination: DateDetails(date: today)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(today.toVeryLongString())
                        Text(today.dayName)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct ConverterWidget: View {
    @State private var from = Date()
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "arrow.left.arrow.right")
            Text("Convertir")
            Spacer()
            Button {
                from = Date()
            } label: {
                Image(systemName: "arrow.up.to.line")
                    .accessibility(label: Text("Revenir à aujourd'hui"))
                    .foregroundColor(.primary)
                    .font(.body)
            }
        } content: {
            DatePicker(selection: $from, in: FrenchRepublicanDate.ORIGIN..., displayedComponents: .date) {
                Text("Date grégorienne : ")
            }
            Divider()
            HStack {
                Text("Date républicaine : ")
                Spacer()
                RepublicanDatePicker(date: Binding(get: {
                    let today = FrenchRepublicanDate(date: from)
                    return MyRepublicanDateComponents(day: today.components.day!, month: today.components.month!, year: today.components.year!)
                }, set: { cmps in
                    from = cmps.toRep.date
                }))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
