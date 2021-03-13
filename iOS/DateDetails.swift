//
//  SwiftUIView.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil Pedersen on 20/04/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI
import Combine

struct DateDetails: View {
    @EnvironmentObject var favoritesPool: FavoritesPool
    
    var date: FrenchRepublicanDate
    
    var gregorian: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE d MMMM yyyy"
        df.locale = Locale(identifier: "fr")
        return df.string(from: date.date)
    }
    
    var iso: String {
        date.date.iso
    }
    
    var body: some View {
        Form {
            Section {
                Text(date.toVeryLongString())
            }
            Section {
                Button {
                    defineDayName()
                } label: {
                    Row(value: date.dayName, title: "Jour :")
                }.contextMenu {
                    Button(action: defineDayName) {
                        Image(systemName: "magnifyingglass")
                        Text("Chercher")
                    }
                    Button(action: openDayNameDescriptionURL) {
                        Image(systemName: "w.circle")
                        Text("Définition")
                    }
                }
                Row(value: date.quarter, title: "Saison :")
                Row(value: "\(date.components.weekOfYear!)/37", title: "Décade :")
                    .accessibility(value: Text("\(date.components.weekOfYear!) sur 37"))
                Row(value: "\(date.dayInYear)/\(date.isYearSextil ? 366 : 365)", title: "Jour de l'année :")
                    .accessibility(value: Text("\(date.dayInYear) sur \(date.isYearSextil ? 366 : 365)"))
                Row(value: gregorian, title: "Grégorien :")
                Row(value: date.toShortenedString(), title: "Date abrégée :")
                    .accessibility(value: Text(date.toShortenedString().replacingOccurrences(of: "/", with: "-")))
            }
        }.navigationBarTitle(date.toLongString())
        .navigationBarItems(trailing: Button(action: {
            if favoritesPool.favorites.contains(iso) {
                favoritesPool.favorites.removeAll { date in
                    self.date.date.iso == date
                }
            } else {
                favoritesPool.favorites.append(self.date.date.iso)
            }
            favoritesPool.sync()
        }) {
            let added = favoritesPool.favorites.contains(iso)
            Image(systemName: added ? "star.fill" : "star")
                .accessibility(label: Text(added ? "Retirer des favoris" : "Ajouter aux favoris"))
        })
    }
    
    func defineDayName() {
        // We're gonna create a new UIKit text view and make it look up the word
        let tv = UITextView()
        tv.text = date.dayName
        tv.isEditable = false // prevents showing the keyboard
        
        guard let root = UIApplication.shared.windows.first?.rootViewController?.view else { return }
        root.addSubview(tv)
        
        tv.selectAll(tv)
        // hi Apple, please add a public API for this
        let sel = Selector(String(":enifed_".reversed()))
        if tv.responds(to: sel) {
            tv.perform(sel, with: tv)
        } else {
            print("cannot define, opening in Safari")
            openDayNameDescriptionURL()
        }
        
        tv.removeFromSuperview()
    }
    
    func openDayNameDescriptionURL() {
        UIApplication.shared.open(date.descriptionURL!)
    }
}

struct Row: View {
    var value: String
    var title: String
    
    var body: some View {
        HStack {
            Text(title).lineLimit(1).layoutPriority(2)
                .foregroundColor(.primary)
            Spacer()
            Text(value).layoutPriority(3)
        }
        .accessibilityElement()
        .accessibility(label: Text(title))
        .accessibility(value: Text(value))
    }
}
