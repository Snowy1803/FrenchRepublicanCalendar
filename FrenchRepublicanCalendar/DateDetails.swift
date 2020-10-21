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
    var date: FrenchRepublicanDate
    
    var gregorian: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE d MMMM yyyy"
        return df.string(from: date.date)
    }
    
    var iso: String {
        date.date.iso
    }
    
    @State var added: Bool = false
    
    var body: some View {
        Form {
            Section {
                Text(date.toVeryLongString())
            }
            Section {
                Row(value: date.dayName, title: "Jour :")
                Row(value: date.quarter, title: "Saison :")
                Row(value: "\(date.components.weekOfYear!)/37", title: "Décade :")
                Row(value: "\(date.dayInYear)/\(date.isYearSextil ? 366 : 365)", title: "Jour de l'année :")
                Row(value: gregorian, title: "Grégorien :")
            }
        }.navigationBarTitle(date.toLongString())
        .navigationBarItems(trailing: Button(action: {
            if var favorites = UserDefaults.standard.array(forKey: "favorites") {
                if self.added {
                    favorites.removeAll(where: { date in
                        iso == date as! String
                    })
                } else {
                    favorites.append(iso)
                }
                UserDefaults.standard.set(favorites, forKey: "favorites")
            } else {
                UserDefaults.standard.set([iso], forKey: "favorites")
            }
            (UIApplication.shared.delegate as! AppDelegate).syncFavorites()
            self.added.toggle()
        }) {
            Image(systemName: added ? "star.fill" : "star")
                .accessibility(label: Text(added ? "Retirer des favoris" : "Ajouter aux favoris"))
        })
        .onAppear {
            self.added = UserDefaults.standard.array(forKey: "favorites")?.contains(where: { date in
                iso == date as! String
            }) ?? false
        }
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
