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
                    self.contentView(fav: fav)
                }
            }
        }.onAppear {
            self.favs = UserDefaults.standard.array(forKey: "favorites") as? [String] ?? [String]()
        }.navigationBarTitle("Favoris")
    }
    
    func contentView(fav: String) -> AnyView {
        let date = self.toDate(fav: fav)
        let frd = FrenchRepublicanDate(date: date)
        return AnyView(
            NavigationLink(destination: DateDetails(components: date.toMyDateComponents, date: frd)) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(frd.toLongStringNoYear())
                        Spacer()
                        Text("\(frd.components.year!)")
                    }
                    Text(self.toHuman(fav: fav)).foregroundColor(.secondary)
                }.padding([.top, .bottom], 2)
            }
        )
    }
    
    func toHuman(fav: String) -> String {
        let df = DateFormatter()
        df.dateFormat = "d MMMM yyyy"
        return df.string(from: toDate(fav: fav))
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
