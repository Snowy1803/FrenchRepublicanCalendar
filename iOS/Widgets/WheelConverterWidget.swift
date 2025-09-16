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
    @State private var userScrolled = false
    @State private var scrolled = false
    @State private var wheelContent = DateCollection()
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "forward")
            Text("Conversion rapide")
            Spacer()
            if userScrolled {
                Button {
                    scrolled = false
                    userScrolled = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .accessibility(label: Text("Recentrer sur aujourd'hui"))
                        .foregroundColor(.secondary)
                        .font(.body)
                }
            }
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
                .onScroll {
                    if userScrolled == false {
                        userScrolled = true
                    }
                }
                .onChange(of: scrolled) { scrolled in
                    if !scrolled {
                        reader.scrollTo(Calendar.gregorian.startOfDay(for: Date()), anchor: .center)
                        self.scrolled = true
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

fileprivate extension View {
    @ViewBuilder func onScroll(perform: @escaping () -> Void) -> some View {
        if #available(iOS 18.0, *) {
            self.onScrollPhaseChange { _, phase in
                if phase == .interacting {
                    perform()
                }
            }
        } else {
            self.simultaneousGesture(DragGesture().onChanged { _ in
                perform()
            })
        }
    }
}

struct WheelDateBackground: ViewModifier {
    @EnvironmentObject var favoritesPool: FavoritesPool
    @EnvironmentObject var midnight: Midnight
    var date: Date
    
    func body(content: Content) -> some View {
        let color = (Calendar.gregorian.isDateInToday(date) ? Color.blue
                     : favoritesPool.favorites.contains(date.iso) ? Color.yellow
                     : Color(white: 0.8)).opacity(0.1)
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(color).interactive(), in: .rect(cornerRadius: 26 - 8))
        } else {
            content.background(color.cornerRadius(10))
        }
    }
}

@available(iOS 14.0, *)
struct WheelDateView: View {
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
                    .foregroundColor(.secondary)
                Text(String(rep.components.day!))
                    .font(.largeTitle)
                Text(rep.monthName)
                Text("An \(rep.formattedYear)")
                Text(rep.dayName)
            }.frame(width: 110)
            .padding()
            .foregroundColor(.primary)
            .accessibilityElement(children: .combine)
            .accessibility(label: Text("\(dateString)\n\(rep.components.day!) \(rep.monthName) An \(rep.components.year!)\n\(rep.dayName)"))
        }
        .modifier(WheelDateBackground(date: date))
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
