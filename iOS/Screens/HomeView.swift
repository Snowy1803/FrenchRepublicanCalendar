//
//  HomeView.swift
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
import Introspect

struct HomeView: View {
    @EnvironmentObject var favoritesPool: FavoritesPool
    @EnvironmentObject var midnight: Midnight
    
    @AppStorage("frc-last-open-build", store: UserDefaults.shared) var lastVersion = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TodayWidget()
                    DecimalTimeWidget(link: true)
                    ConverterWidget()
                    WheelConverterWidget()
                    LinkWidget(
                        destination: FavoriteList(),
                        imageSystemName: "text.badge.star",
                        title: Text("Mes Favoris"),
                        data: Text(String(favoritesPool.favorites.count))
                    ).accessibility(label: Text("Voir mes \(favoritesPool.favorites.count) favoris"))
                    LinkWidget(
                        destination: ContactsList(),
                        imageSystemName: "person.2",
                        title: Text("Mes Contacts"),
                        data: nil
                    ).accessibility(label: Text("Voir mes contacts"))
                    LinkWidget(
                        destination: VariantPicker(),
                        imageSystemName: "gear",
                        title: Text("Calendriers républicains"),
                        data: Text(FrenchRepublicanDateOptions.current.variant.description)
                    )
                    .accessibility(label: Text("Changer de variante de calendrier républicain"))
                    .accessibility(value: Text(FrenchRepublicanDateOptions.current.variant.description))
                    .padding(.bottom)
                }.notTooWide()
            }.navigationBarTitle("Calendrier Républicain")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
