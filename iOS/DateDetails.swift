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
                    UIApplication.shared.open(date.descriptionURL!)
                } label: {
                    Row(value: date.dayName, title: "Jour :")
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