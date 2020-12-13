//
//  ContentView.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var favorites: FavoritesPool
    
    @State var shownDateGregorian = Date().toMyDateComponents
    @State var shownDateRepublican = Date().toMyDateComponents // Overridden before use
    
    @State var converter: Bool = false
    
    @State var gtrActive = true // When opened, Gregorian To Republican is the default view
    @State var rtgActive = false
    
    @State var todayActive = false
    
    var body: some View {
        List {
            NavigationLink(destination: DateDetails(favoritesPool: favorites, components: Date().toMyDateComponents, date: FrenchRepublicanDate(date: Date())), isActive: Binding<Bool>(get: { self.todayActive }, set: {
                if $0 {
                    self.shownDateGregorian = Date().toMyDateComponents
                    self.shownDateRepublican = FrenchRepublicanDate(date: Date()).toMyDateComponents
                    self.todayActive = true
                } else {
                    self.todayActive = false
                }
            })) {
                HStack {
                    Image(systemName: "calendar").frame(width: 20, height: 20)
                    Text("Aujourd'hui")
                }
            }
            NavigationLink(destination: GregorianToRepublicanView(favoritesPool: favorites, shownDate: $shownDateGregorian), isActive: Binding<Bool>(get: { self.gtrActive }, set: {
                if $0 {
                    self.gtrActive = true
                } else {
                    self.gtrActive = false
                    self.shownDateRepublican = self.shownDateGregorian.tofrd!.toMyDateComponents
                }
            })) {
                HStack {
                    Image(systemName: "doc.text").frame(width: 20, height: 20)
                    Text("Vers Républicain")
                }
            }
            NavigationLink(destination: RepublicanToGregorianView(shownDate: $shownDateRepublican), isActive: Binding<Bool>(get: { self.rtgActive }, set: {
                if $0 {
                    self.rtgActive = true
                } else {
                    self.rtgActive = false
                    self.shownDateGregorian = self.shownDateRepublican.asfrd.date.toMyDateComponents
                }
            })) {
                HStack {
                    Image(systemName: "map").frame(width: 20, height: 20)
                    Text("Vers Grégorien")
                }
            }
            NavigationLink(destination: FavoriteList(pool: favorites)) {
                HStack {
                    Image(systemName: "text.badge.star").frame(width: 20, height: 20)
                    Text("Mes favoris (\(favorites.favorites.count))")
                }
            }
            NavigationLink(destination: ContactsList(favoritesPool: favorites)) {
                HStack {
                    Image(systemName: "person.2").frame(width: 20, height: 20)
                    Text("Mes contacts")
                }
            }
        }.navigationBarTitle("Cal Républicain")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(favorites: FavoritesPool())
    }
}
