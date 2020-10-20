//
//  ContentView.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var shownDateGregorian = Date().toMyDateComponents
    @State var shownDateRepublican = Date().toMyDateComponents // Overridden before use
    
    @State var converter: Bool = false
    
    @State var gtrActive = true // When opened, Gregorian To Republican is the default view
    @State var rtgActive = false
    
    @State var todayActive = false
    
    var body: some View {
        List {
            NavigationLink(destination: DateDetails(components: Date().toMyDateComponents, date: FrenchRepublicanDate(date: Date())), isActive: Binding<Bool>(get: { self.todayActive }, set: {
                if $0 {
                    self.shownDateGregorian = Date().toMyDateComponents
                    self.shownDateRepublican = FrenchRepublicanDate(date: Date()).toMyDateComponents
                    self.todayActive = true
                } else {
                    self.todayActive = false
                }
            })) {
                HStack {
                    Image(systemName: "calendar").frame(width: 20, height: 20)
                    Text("Aujourd'hui")
                }
            }
            NavigationLink(destination: GregorianToRepublicanView(shownDate: $shownDateGregorian), isActive: Binding<Bool>(get: { self.gtrActive }, set: {
                if $0 {
                    self.gtrActive = true
                } else {
                    self.gtrActive = false
                    self.shownDateRepublican = self.shownDateGregorian.tofrd!.toMyDateComponents
                }
            })) {
                HStack {
                    Image(systemName: "doc.text").frame(width: 20, height: 20)
                    Text("Vers Républicain")
                }
            }
            NavigationLink(destination: RepublicanToGregorianView(shownDate: $shownDateRepublican), isActive: Binding<Bool>(get: { self.rtgActive }, set: {
                if $0 {
                    self.rtgActive = true
                } else {
                    self.rtgActive = false
                    self.shownDateGregorian = self.shownDateRepublican.asfrd.date.toMyDateComponents
                }
            })) {
                HStack {
                    Image(systemName: "map").frame(width: 20, height: 20)
                    Text("Vers Grégorien")
                }
            }
            NavigationLink(destination: FavoriteList()) {
                HStack {
                    Image(systemName: "text.badge.star").frame(width: 20, height: 20)
                    Text("Mes favoris")
                }
            }
            NavigationLink(destination: ContactsList()) {
                HStack {
                    Image(systemName: "person.2").frame(width: 20, height: 20)
                    Text("Mes contacts")
                }
            }
        }.navigationBarTitle("Cal Républicain")
    }
}

struct GregorianToRepublicanView: View {
    @Binding var shownDate: MyDateComponents
    
    var body: some View {
        VStack {
            NavigationLink(destination: DateDetails(components: shownDate, date: shownDate.tofrd!)) {
                Text(shownDate.tofrd!.toLongString())
            }
            HStack {
                Picker(selection: $shownDate.day.wrapped, label: EmptyView()) {
                    ForEach(Calendar.current.range(of: .day, in: .month, for: shownDate.asdate!)!, id: \.self) { day in
                        Text("\(day)").tag(day.wrapped)
                    }
                }
                Picker(selection: $shownDate.month.wrapped, label: EmptyView()) {
                    ForEach(1..<13) { month in
                        Text("\(Calendar.current.shortMonthSymbols[month - 1])").tag(month.wrapped)
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
                        Text("\(FrenchRepublicanDate.MONTH_NAMES_SHORT[month - 1])").tag(month.wrapped)
                    }
                }
            }
            Picker(selection: $shownDate.year.wrapped, label: EmptyView()) {
                ForEach(0..<2708) { year in
                    Text("\(String(year))").tag(year.wrapped)
                }
            }
        }.navigationBarTitle("Rép > Grég")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MyDateComponents {
    var day: Int
    var month: Int
    var year: Int
    
    var asdate: Date? {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }
    
    var tofrd: FrenchRepublicanDate? {
        let date = self.asdate
        return date == nil ? nil : FrenchRepublicanDate(date: date!)
    }
    
    var asfrd: FrenchRepublicanDate {
        return FrenchRepublicanDate(dayInYear: (month - 1) * 30 + day, year: year)
    }
    
    var todate: Date {
        return self.asfrd.date
    }
    
    var string: String {
        "\(year)-\(month)-\(day)"
    }
}

extension Date {
    var toMyDateComponents: MyDateComponents {
        let comp = Calendar.current.dateComponents([.day, .month, .year], from: self)
        return MyDateComponents(day: comp.day!, month: comp.month!, year: comp.year!)
    }
}

extension FrenchRepublicanDate {
    var toMyDateComponents: MyDateComponents {
        return MyDateComponents(day: components.day!, month: components.month!, year: components.year!)
    }
}


