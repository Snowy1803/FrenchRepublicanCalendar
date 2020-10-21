//
//  FavoriteList.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil Pedersen on 20/04/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

struct FavoriteList: View {
    @ObservedObject var pool: FavoritesPool
    
    var body: some View {
        Group {
            if pool.favorites.isEmpty {
                Text("Aucun favori")
            } else {
                List(pool.favorites.reversed(), id: \.self) { fav in
                    DateRow(favoritesPool: pool, frd: FrenchRepublicanDate(date: self.toDate(fav: fav)))
                }
            }
        }.navigationBarTitle("Favoris")
    }
    
    func toDate(fav: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-M-d"
        return df.date(from: fav)!
    }
}
