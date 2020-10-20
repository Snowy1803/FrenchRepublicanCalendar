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
                    NavigationLink(destination: FavoriteList()) {
                        HStack {
                            Image.decorative(systemName: "text.badge.star")
                                .frame(width: 25)
                            Text("Mes Favoris")
                            Spacer()
                            Text(String((UserDefaults.standard.array(forKey: "favorites") as? [String])?.count ?? 0))
                            Image.decorative(systemName: "chevron.right")
                        }
                    }.shadowBox()
                    NavigationLink(destination: FavoriteList()) {
                        HStack {
                            Image.decorative(systemName: "person.2")
                                .frame(width: 25)
                            Text("Mes Contacts")
                            Spacer()
                            Image.decorative(systemName: "chevron.right")
                        }
                    }.shadowBox()
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
                    Text(String(today.components.day!))
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text(today.monthName)
                        Text(today.dayName)
                    }
                    Spacer()
                    Image.decorative(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }.foregroundColor(.primary)
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
            let rep = FrenchRepublicanDate(date: from)
            DatePicker(selection: $from, in: FrenchRepublicanDate.ORIGIN..., displayedComponents: .date) {
                Text("Date grégorienne : ")
            }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
