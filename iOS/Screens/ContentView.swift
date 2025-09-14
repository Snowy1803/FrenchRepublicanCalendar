//
//  ContentView.swift
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

struct ContentView: View {
    @EnvironmentObject var favoritesPool: FavoritesPool
    @EnvironmentObject var midnight: Midnight
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TodayWidget()
                    DecimalTimeWidget(link: true)
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
                    .accessibility(label: Text("Changer de variante de calendrier républicain"))
                    .accessibility(value: Text(FrenchRepublicanDateOptions.current.variant.description))
                    .padding(.bottom)
                }.notTooWide()
            }.navigationBarTitle("Calendrier Républicain")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func notTooWide() -> some View {
        self.modifier(ReadableContentFollowingModifier())
            .modifier(ReadableContentMeasuringModifier())
    }
    
    func listNotTooWide() -> some View {
        self.introspectTableView { tableView in
            // iOS 15
            tableView.cellLayoutMarginsFollowReadableWidth = true
        }.introspectCollectionView { collectionView in
            // iOS 16
            guard #available(iOS 16, *) else {
                return
            }
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewCompositionalLayout,
                  layout.responds(to: Selector(("layoutSectionProvider"))) else {
                return // impl changed, abort
            }
            // this is very hacky
            let ogProvider = unsafeBitCast(
                layout.value(forKey: "_layoutSectionProvider") as AnyObject,
                to: (@convention(block) (Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?).self)
            collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
                let section = ogProvider(sectionIndex, layoutEnvironment)
                section?.contentInsetsReference = .readableContent
                return section
            }
        }
    }
}
