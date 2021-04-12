//
//  ContentView.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct ContentView: View {
    @EnvironmentObject var favoritesPool: FavoritesPool
    @EnvironmentObject var midnight: Midnight
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TodayWidget()
                    ConverterWidget()
                    if #available(iOS 14, *) {
                        WheelConverterWidget()
                    }
                    NavigationLink(destination: FavoriteList()) {
                        HStack {
                            Image.decorative(systemName: "text.badge.star")
                                .frame(width: 25)
                            Text("Mes Favoris")
                            Spacer()
                            Text(String(favoritesPool.favorites.count))
                            Image.decorative(systemName: "chevron.right")
                        }
                    }.shadowBox()
                    .accessibility(label: Text("Voir mes \(favoritesPool.favorites.count) favoris"))
                    NavigationLink(destination: ContactsList()) {
                        HStack {
                            Image.decorative(systemName: "person.2")
                                .frame(width: 25)
                            Text("Mes Contacts")
                            Spacer()
                            Image.decorative(systemName: "chevron.right")
                        }
                    }.shadowBox()
                    .accessibility(label: Text("Voir mes contacts"))
                    
                    Toggle(isOn: Binding {
                        FrenchRepublicanDateOptions.current.romanYear
                    } set: {
                        FrenchRepublicanDateOptions.current.romanYear = $0
                        midnight.objectWillChange.send()
                    }) {
                        Text("Chiffres romains pour les années")
                    }.shadowBox()
                    
                    NavigationLink(destination: VariantPicker()) {
                        HStack {
                            Image.decorative(systemName: "gear")
                                .frame(width: 25)
                            Text("Calendriers républicains")
                            Spacer()
                            Text(FrenchRepublicanDateOptions.current.variant.description)
                                .foregroundColor(.secondary)
                            Image.decorative(systemName: "chevron.right")
                                .imageScale(.small)
                                .foregroundColor(.secondary)
                        }.foregroundColor(.primary)
                    }.shadowBox()
                    .accessibility(label: Text("Changer de variant de calendrier républicain"))
                    .accessibility(value: Text(FrenchRepublicanDateOptions.current.variant.description))
                    .padding(.bottom)
                }
            }.navigationBarTitle("Calendrier Républicain")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
