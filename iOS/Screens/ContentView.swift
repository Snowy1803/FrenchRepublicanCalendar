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
@_spi(Advanced) import SwiftUIIntrospect

struct ContentView: View {
    @EnvironmentObject var favoritesPool: FavoritesPool
    @EnvironmentObject var midnight: Midnight
    
    @AppStorage("frc-last-open-build", store: UserDefaults.shared) var lastVersion = 0
    
    var body: some View {
        if lastVersion < WhatsNew.lastSignificantChange {
            NavigationView {
                WhatsNew()
            }
            .navigationViewStyle(.stack)
        } else {
            TabView {
                HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Accueil")
                }
                NavigationView {
                    ScrollableCalendarView()
                }
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendrier")
                }
                NavigationView {
                    SettingsView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Réglages")
                }
            }
        }
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
        self.introspect(.list, on: .iOS(.v15)) { tableView in
            // iOS 15
            tableView.cellLayoutMarginsFollowReadableWidth = true
        }.introspect(.list, on: .iOS(.v16...)) { collectionView in
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
