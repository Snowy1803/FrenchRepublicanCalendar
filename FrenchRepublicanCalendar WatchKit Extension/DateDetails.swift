//
//  SwiftUIView.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil Pedersen on 20/04/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

struct DateDetails: View {
    let QUARTERS = ["Automne", "Hiver", "Printemps", "Été", "Sansculottides"]
    var date: FrenchRepublicanDate
    
    var body: some View {
        ScrollView {
            VStack {
                Text(date.toLongStringNoYear())
                Row(value: "\(date.components.year!)", title: "An :")
                Row(value: "\(date.weekdayName)", title: "Jour :")
                Row(value: "\(QUARTERS[date.components.quarter! - 1])", title: "Saison :")
                Row(value: "\(date.components.weekOfYear!)/37", title: "Décade :")
                Row(value: "\(date.dayInYear)/\(date.isYearSextil ? 366 : 365)", title: "Jour :")
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
        DateDetails(date: FrenchRepublicanDate(date: Date()))
    }
}
