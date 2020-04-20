//
//  ContentView.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var shownDate = Date().toMyDateComponents
    
    var body: some View {
        VStack {
            NavigationLink(destination: DateDetails(date: shownDate.frd!)) {
                Text(shownDate.frd!.toLongString())
            }
            HStack {
                Picker(selection: $shownDate.day.wrapped, label: EmptyView()) {
                    ForEach(Calendar.current.range(of: .day, in: .month, for: shownDate.date!)!, id: \.self) { day in
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
        }.contextMenu {
            Button(action: {
                self.shownDate = Date().toMyDateComponents
            }) {
                VStack {
                    Image(systemName: "calendar")
                    Text("Aujourd'hui")
                }
            }
        }
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
    
    var date: Date? {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }
    
    var frd: FrenchRepublicanDate? {
        let date = self.date
        return date == nil ? nil : FrenchRepublicanDate(date: date!)
    }
}

extension Date {
    var toMyDateComponents: MyDateComponents {
        let comp = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        return MyDateComponents(day: comp.day!, month: comp.month!, year: comp.year!)
    }
}

// When using ints as tags, it doesn't work...

extension Int {
    var wrapped: IntWrapper {
        get {
            IntWrapper(value: self)
        }
        set {
            self = newValue.value
        }
    }
}

struct IntWrapper: Hashable {
    var value: Int
}
