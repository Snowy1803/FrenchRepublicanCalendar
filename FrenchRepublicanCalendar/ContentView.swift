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
                    HomeWidget {
                        Image.decorative(systemName: "calendar")
                        Text("Aujourd'hui")
                    } content: {
                        let today = FrenchRepublicanDate(date: Date())
                        HStack {
                            VStack(alignment: .leading) {
                                Text(today.toVeryLongString())
                                Text(today.dayName)
                            }
                            Spacer()
                        }
                    }
                    GregToRepWidget()
                }
            }.navigationBarTitle("Calendrier républicain")
        }
    }
}

struct GregToRepWidget: View {
    @State private var from = Date()
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "doc.text")
            Text("Grégorien vers Républicain")
        } content: {
            DatePicker(selection: $from, in: FrenchRepublicanDate.ORIGIN..., displayedComponents: .date) {
                Text("Date grégorienne : ")
            }
        } footer: {
            let today = FrenchRepublicanDate(date: from)
            HStack {
                Text(today.toLongString())
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
