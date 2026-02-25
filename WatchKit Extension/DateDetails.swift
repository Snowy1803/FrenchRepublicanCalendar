//
//  SwiftUIView.swift
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
import Combine

struct DateDetails: View {
    @EnvironmentObject var favoritesPool: FavoritesPool
    
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
                VStack {
                    Text(date, format: .republicanDate.day())
                        .font(.headline)
                    Text(date, format: .republicanDate.year())
                        .foregroundStyle(.secondary)
                    Divider()
                    VStack(alignment: .leading) {
                        Text(date, format: .republicanDate.day(.dayName))
                        Text(date.dayNameGrammaticalNature.natureDescription)
                            .foregroundColor(.secondary)
                        Text(date.dayNameExplanation)
                            .multilineTextAlignment(.leading)
                    }
                    Divider()
                    Row(value: date.weekdayName, title: "Jour :")
                    Row(value: date.quarter, title: "Saison :")
                    Row(value: "\(date.components.weekOfYear!)/37", title: "Décade :")
                    Row(value: "\(date.dayInYear)/\(date.isYearSextil ? 366 : 365)", title: "Jour :")
                    Row(value: gregorian, title: "Grég. :")
                    Row(value: date.toShortenedString(), title: "Abrégé :")
                }.scenePadding()
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
            .ensureSmallBarTitle()
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

extension FrenchRepublicanDate.DayNameNature {
    var natureDescription: LocalizedStringKey {
        switch self {
        case .nm:
            "nom masculin"
        case .nf:
            "nom féminin"
        case .nmpl:
            "nom masculin pluriel"
        case .nfpl:
            "nom féminin pluriel"
        }
    }
}
