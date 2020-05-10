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
    let QUARTERS = ["Automne", "Hiver", "Printemps", "Été", "Sansculottides"]
    var components: MyDateComponents
    var date: FrenchRepublicanDate
    
    var gregorian: String {
        let day = components.asdate!
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy"
        return df.string(from: day)
    }
    
    @State var added: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text(date.toLongStringNoYear())
                Row(value: "\(date.components.year!)", title: "An :")
                Row(value: "\(date.dayName)", title: "\(date.weekdayName)")
                Row(value: "\(QUARTERS[date.components.quarter! - 1])", title: "Saison :")
                Row(value: "\(date.components.weekOfYear!)/37", title: "Décade :")
                Row(value: "\(date.dayInYear)/\(date.isYearSextil ? 366 : 365)", title: "Jour :")
                Row(value: "\(gregorian)", title: "Grég. :")
                Button(action: {
                    if var favorites = UserDefaults.standard.array(forKey: "favorites") {
                        if self.added {
                            favorites.removeAll(where: { date in
                                self.components.string == date as! String
                            })
                        } else {
                            favorites.append(self.components.string)
                        }
                        UserDefaults.standard.set(favorites, forKey: "favorites")
                    } else {
                        UserDefaults.standard.set([self.components.string], forKey: "favorites")
                    }
                    self.added.toggle()
                }) {
                    HStack {
                        Image(systemName: added ? "star.fill" : "star")
                        Text(added ? "Enregistré " : "Enregistrer")
                    }
                }.onAppear {
                    self.added = UserDefaults.standard.array(forKey: "favorites")?.contains(where: { date in
                        self.components.string == date as! String
                    }) ?? false
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

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        DateDetails(components: Date().toMyDateComponents, date: FrenchRepublicanDate(date: Date()))
    }
}
