//
//  WheelConverterWidget.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 28/11/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

@available(iOS 14.0, *)
struct WheelConverterWidget: View {
    @State var scrolled = false
    @State var wheelContent = DateCollection()
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "forward")
            Text("Conversion rapide")
            Spacer()
        } content: {
            ScrollViewReader { reader in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(wheelContent, id: \.self) { date in
                            WheelDateView(date: date)
                        }
                    }
                }.onAppear {
                    if !scrolled {
                        print("Starting at", wheelContent.first ?? "nil")
                        reader.scrollTo(Calendar.gregorian.startOfDay(for: Date()), anchor: .center)
                        scrolled = true
                    }
                }
            }.mask(LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .white, location: 0.1),
                        .init(color: .white, location: 0.9),
                        .init(color: .clear, location: 1)
                    ]),
                    startPoint: .leading, endPoint: .trailing)
            )
        }
    }
}

@available(iOS 14.0, *)
struct WheelDateView: View {
    @EnvironmentObject var favoritesPool: FavoritesPool
    @EnvironmentObject var midnight: Midnight
    var date = Date()
    
    var dateString: String {
        let format = DateFormatter()
        format.dateStyle = .long
        format.timeStyle = .none
        format.doesRelativeDateFormatting = true
        format.locale = Locale(identifier: "fr-FR")
        return format.string(from: date)
    }
    
    var body: some View {
        let rep = FrenchRepublicanDate(date: date)
        NavigationLink(destination: DateDetails(date: rep)) {
            VStack {
                Text(dateString)
                    .font(.caption)
                Text(String(rep.components.day!))
                    .font(.largeTitle)
                Text(rep.monthName)
                Text("An \(rep.formattedYear)")
                Text(rep.dayName)
            }.frame(width: 110)
            .padding()
            .background(
                (Calendar.gregorian.isDateInToday(date) ? Color.blue : favoritesPool.favorites.contains(date.iso) ? Color.yellow : Color.gray)
                    .opacity(0.15)
                    .cornerRadius(10)
            ).foregroundColor(.primary)
            .accessibilityElement(children: .combine)
            .accessibility(label: Text("\(dateString)\n\(rep.components.day!) \(rep.monthName) An \(rep.components.year!)\n\(rep.dayName)"))
        }
    }
}

@available(iOS 14.0, *)
struct DateCollection: RandomAccessCollection {
    var startDate = Calendar.gregorian.startOfDay(for: FrenchRepublicanDate.origin)
    
    var startIndex: Int = {
        if #available(iOS 16, *) {
            return 82440 // workaround FB11396644 (ScrollViewReader for LazyHStack is not lazy anymore)
        } else {
            return 0
        }
    }()
    var endIndex: Int = 4933795
    
    typealias Element = Date
    typealias Index = Int
    typealias SubSequence = Array
    typealias Indices = Range<Int>
    
    subscript(position: Int) -> Date {
        get {
            Calendar.gregorian.date(byAdding: .day, value: position, to: startDate)!
        }
    }
}
