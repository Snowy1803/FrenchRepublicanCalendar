//
//  ContentView.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

struct GregorianToRepublicanView: View {
    @ObservedObject var favoritesPool: FavoritesPool
    @Binding var shownDate: MyDateComponents
    
    var body: some View {
        VStack {
            NavigationLink(destination: DateDetails(favoritesPool: favoritesPool, components: shownDate, date: shownDate.tofrd!)) {
                Text(shownDate.tofrd!.toLongString())
            }
            HStack {
                Picker(selection: $shownDate.day.wrapped, label: EmptyView()) {
                    ForEach(Calendar.gregorian.range(of: .day, in: .month, for: shownDate.asdate!)!, id: \.self) { day in
                        Text("\(day)").tag(day.wrapped)
                    }
                }
                Picker(selection: $shownDate.month.wrapped, label: EmptyView()) {
                    ForEach(1..<13) { month in
                        Text("\(Calendar.gregorian.shortMonthSymbols[month - 1])").tag(month.wrapped)
                    }
                }
            }
            Picker(selection: $shownDate.year.wrapped, label: EmptyView()) {
                ForEach(1792..<4500) { year in
                    Text("\(String(year))").tag(year.wrapped)
                }
            }
        }.navigationBarTitle("Grég > Rép")
    }
}
