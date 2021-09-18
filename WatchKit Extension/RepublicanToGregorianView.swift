//
//  ContentView.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct RepublicanToGregorianView: View {
    @Binding var shownDate: MyDateComponents
    
    var dateString: String {
        let df = DateFormatter()
        df.dateFormat = "EEE d MMM yyyy"
        return df.string(from: shownDate.todate)
    }
    
    var body: some View {
        VStack {
            Text(dateString).padding([.top, .bottom], 5)
            HStack {
                Picker(selection: $shownDate.day.wrapped, label: EmptyView()) {
                    ForEach(1..<(shownDate.month < 13 ? 31 : shownDate.year % 4 == 0 ? 7 : 6), id: \.self) { day in
                        Text("\(day)").tag(day.wrapped)
                    }
                }
                Picker(selection: $shownDate.month.wrapped, label: EmptyView()) {
                    ForEach(1..<14) { month in
                        Text("\(FrenchRepublicanDate.shortMonthNames[month - 1])").tag(month.wrapped)
                    }
                }
            }
            Picker(selection: $shownDate.year.wrapped, label: EmptyView()) {
                ForEach(1..<2708) { year in
                    Text("\(FrenchRepublicanDate(dayInYear: 1, year: year).formattedYear)").tag(year.wrapped)
                }
            }
        }.navigationBarTitle("Rép > Grég")
            .ensureSmallBarTitle()
    }
}
