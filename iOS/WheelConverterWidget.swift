//
//  WheelConverterWidget.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 28/11/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

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
                        reader.scrollTo(Calendar.current.startOfDay(for: Date()), anchor: .center)
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
                Text("An \(rep.components.year!)")
                Text(rep.dayName)
            }.frame(width: 110)
            .padding()
            .background(
                (Calendar.current.isDateInToday(date) ? Color.blue : favoritesPool.favorites.contains(date.iso) ? Color.yellow : Color.gray)
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
    var startDate = Calendar.current.startOfDay(for: FrenchRepublicanDate.origin)
    
    var startIndex: Int = 0
    var endIndex: Int = 4933795
    
    typealias Element = Date
    typealias Index = Int
    typealias SubSequence = Array
    typealias Indices = Range<Int>
    
    subscript(position: Int) -> Date {
        get {
            Calendar.current.date(byAdding: .day, value: position, to: startDate)!
        }
    }
}
