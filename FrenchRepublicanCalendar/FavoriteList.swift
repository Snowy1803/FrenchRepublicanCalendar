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
                VStack {
                    Text("Aucun favori")
                        .font(.title)
                        .padding(.bottom)
                    if #available(iOS 14.0, *) {
                        Text("Ajoutez-en en appuyant sur \(Image(systemName: "star")) dans les détails d'une date")
                            .padding(.bottom, 100)
                    } else {
                        Text("Ajoutez-en en appuyant sur l'étoile dans les détails d'une date")
                            .padding(.bottom, 100)
                    }
                }.multilineTextAlignment(.center)
            } else {
                Form {
                    ForEach(favs.reversed(), id: \.self) { fav in
                        DateRow(frd: FrenchRepublicanDate(date: self.toDate(fav: fav)))
                    }
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

struct DateRow: View {
    var frd: FrenchRepublicanDate
    var desc: String?
    
    var human: String {
        if Calendar.current.isDateInToday(frd.date) {
            return "Aujourd'hui"
        }
        let df = DateFormatter()
        df.dateFormat = "d MMMM yyyy"
        return df.string(from: frd.date)
    }
    
    var body: some View {
        NavigationLink(destination: DateDetails(date: frd)) {
            VStack(alignment: .leading) {
                Text(frd.toLongString())
                HStack {
                    Text(human).foregroundColor(.secondary)
                    Spacer()
                    if desc != nil {
                        Text(desc!)
                    }
                }
            }.padding([.top, .bottom], 2)
        }
    }
}

struct FavoriteList_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteList()
    }
}
