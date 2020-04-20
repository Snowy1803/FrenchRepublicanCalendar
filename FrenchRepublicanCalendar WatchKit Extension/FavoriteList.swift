//
//  FavoriteList.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil Pedersen on 20/04/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

struct FavoriteList: View {
    @State var favs = [String]()
    
    var body: some View {
        Group {
            if favs.isEmpty {
                Text("Aucun favori")
            } else {
                List(favs.reversed(), id: \.self) { fav in
                    DateRow(date: self.toDate(fav: fav), frd: FrenchRepublicanDate(date: self.toDate(fav: fav)))
                }
            }
        }.onAppear {
            self.favs = UserDefaults.standard.array(forKey: "favorites") as? [String] ?? [String]()
        }.navigationBarTitle("Favoris")
    }
    
    func toDate(fav: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-M-d"
        return df.date(from: fav)!
    }
}

struct FavoriteList_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteList()
    }
}
