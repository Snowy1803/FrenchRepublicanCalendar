//
//  FavoriteList.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil Pedersen on 20/04/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct FavoriteList: View {
    @EnvironmentObject var pool: FavoritesPool
    
    var body: some View {
        Group {
            if pool.favorites.isEmpty {
                VStack {
                    Text("Aucun favori")
                        .font(.title)
                        .padding(.bottom)
                    Text("Ajoutez-en en appuyant sur \(Image(systemName: "star")) dans les détails d'une date")
                        .padding(.bottom, 100)
                }.multilineTextAlignment(.center)
            } else {
                Form {
                    ForEach(pool.favorites.reversed(), id: \.self) { fav in
                        DateRow(frd: FrenchRepublicanDate(date: self.toDate(fav: fav)))
                    }.onDelete { indices in
                        pool.favorites.remove(atOffsets: IndexSet(indices.map { pool.favorites.count - 1 - $0 }))
                    }.onMove { indices, position in
                        pool.favorites.move(fromOffsets: IndexSet(indices.map { pool.favorites.count - 1 - $0 }), toOffset: pool.favorites.count - position)
                    }
                }.editableList()
                .listNotTooWide()
            }
        }.navigationBarTitle("Favoris")
    }
    
    func toDate(fav: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-M-d"
        return df.date(from: fav)!
    }
}

struct DateRow: View {
    var frd: FrenchRepublicanDate
    var desc: String?
    
    var human: String {
        if Calendar.gregorian.isDateInToday(frd.date) {
            return "Aujourd'hui"
        }
        let df = DateFormatter()
        df.dateFormat = "d MMMM yyyy"
        df.locale = Locale(identifier: "fr")
        return df.string(from: frd.date)
    }
    
    var body: some View {
        NavigationLink(destination: DateDetails(date: frd)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(frd.toLongString())
                    Text(human).foregroundColor(.secondary)
                }
                Spacer()
                if desc != nil {
                    Text(desc!)
                }
            }.padding([.top, .bottom], 2)
            .accessibilityElement(children: .combine)
            .accessibility(label: Text("\(frd.toLongString()) ; Soit \(Calendar.gregorian.isDateInToday(frd.date) ? "aujourd'hui" : "le \(human) dans le calendrier grégorien")"))
        }
        
    }
}

extension View {
    @ViewBuilder func editableList() -> some View {
        self.toolbar {
            EditButton()
        }
    }
}

struct FavoriteList_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteList()
    }
}
