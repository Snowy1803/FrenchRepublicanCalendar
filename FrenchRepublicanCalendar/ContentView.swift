//
//  ContentView.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 20/10/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TodayWidget()
                    GregToRepWidget()
                    RepToGregWidget()
                }
            }.navigationBarTitle("Calendrier républicain")
        }
    }
}

struct TodayWidget: View {
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "calendar")
            Text("Aujourd'hui")
        } content: {
            let today = FrenchRepublicanDate(date: Date())
            HStack {
                VStack(alignment: .leading) {
                    Text(today.toVeryLongString())
                    Text(today.dayName)
                }
                Spacer()
            }
        }
    }
}

struct GregToRepWidget: View {
    @State private var from = Date()
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "doc.text")
            Text("Grégorien vers Républicain")
        } content: {
            DatePicker(selection: $from, in: FrenchRepublicanDate.ORIGIN..., displayedComponents: .date) {
                Text("Date grégorienne : ")
            }
        } footer: {
            let today = FrenchRepublicanDate(date: from)
            HStack {
                Text("Date républicaine : ")
                Spacer()
                Text(today.toLongString())
            }
        }
    }
}

struct RepToGregWidget: View {
    @State private var from: MyRepublicanDateComponents = {
        let today = FrenchRepublicanDate(date: Date())
        return MyRepublicanDateComponents(day: today.components.day!, month: today.components.month!, year: today.components.year!)
    }()
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "map")
            Text("Républicain vers Grégorien")
        } content: {
            HStack {
                Text("Date républicaine : ")
                Spacer()
                Text(from.toRep.toLongString())
            }
        } footer: {
            let greg: String = {
                let format = DateFormatter()
                format.dateFormat = "EEEE d MMMM yyyy"
                return format.string(from: from.toRep.date)
            }()
            HStack {
                Text("Date grégorienne : ")
                Spacer()
                Text(greg)
            }
        }
    }
}

struct MyRepublicanDateComponents {
    var day: Int
    var month: Int
    var year: Int
    
    var toRep: FrenchRepublicanDate {
        return FrenchRepublicanDate(dayInYear: (month - 1) * 30 + day, year: year)
    }
    
    var string: String {
        "\(year)-\(month)-\(day)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
