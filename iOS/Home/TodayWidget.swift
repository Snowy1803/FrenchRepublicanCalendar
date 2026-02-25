//
//  TodayWidget.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct TodayWidget: View {
    @EnvironmentObject var midnight: Midnight
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "calendar")
            Text("Aujourd'hui")
            Spacer()
        } content: {
            let today = FrenchRepublicanDate(date: Date())
            NavigationLink(destination: DateDetails(date: today)) {
                HStack {
                    Text(String(today.components.day!))
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text(today.monthName)
                        Text(today, format: .republicanDate.day(.dayName).dayLength(.long))
                    }
                    Spacer()
                    Image.decorative(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }.foregroundColor(.primary)
            }.accessibility(label: Text("\((today.components.day!)) \(today.monthName) ; Associé à : \(today.dayName)"))
        }
    }
}
