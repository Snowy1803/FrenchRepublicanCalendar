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
    
    @ObservedObject var favoritesPool: FavoritesPool
    
    var components: MyDateComponents
    var date: FrenchRepublicanDate
    
    var gregorian: String {
        let day = components.asdate!
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy"
        return df.string(from: day)
    }
    
    var added: Bool {
        favoritesPool.favorites.contains(self.components.string)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(date.toLongStringNoYear())
                Row(value: "\(date.components.year!)", title: "An :")
                Row(value: date.dayName, title: date.weekdayName)
                Row(value: date.quarter, title: "Saison :")
                Row(value: "\(date.components.weekOfYear!)/37", title: "Décade :")
                Row(value: "\(date.dayInYear)/\(date.isYearSextil ? 366 : 365)", title: "Jour :")
                Row(value: gregorian, title: "Grég. :")
                Button(action: {
                    if self.added {
                        favoritesPool.favorites.removeAll { date in
                            self.components.string == date
                        }
                    } else {
                        favoritesPool.favorites.append(self.components.string)
                    }
                    favoritesPool.sync()
                }) {
                    HStack {
                        Image(systemName: added ? "star.fill" : "star")
                        Text(added ? "Enregistré " : "Enregistrer")
                    }
                }
            }
        }.navigationBarTitle("Date")
    }
}

struct Row: View {
    var value: String
    var title: String
    
    var body: some View {
        HStack {
            Text(title).lineLimit(1).layoutPriority(2)
            Spacer()
            Text(value).layoutPriority(3)
        }
    }
}
