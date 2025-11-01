//
//  SwiftUIView.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil Pedersen on 20/04/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
import Combine

struct DateDetails: View {
    @EnvironmentObject var favoritesPool: FavoritesPool
    
    var date: FrenchRepublicanDate
    
    var gregorian: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE d MMMM yyyy"
        df.locale = Locale(identifier: "fr")
        return df.string(from: date.date)
    }
    
    var iso: String {
        date.date.iso
    }
    
    var body: some View {
        Form {
            Section {
                Text(date.toVeryLongString())
            }
            Section {
                DayNameButton(date: date)
            }
            Section {
                Row(value: date.quarter, title: "Saison :")
                Row(value: "\(date.components.weekOfYear!)/37", title: "Décade :")
                    .accessibility(value: Text("\(date.components.weekOfYear!) sur 37"))
                Row(value: "\(date.dayInYear)/\(date.isYearSextil ? 366 : 365)", title: "Jour de l'année :")
                    .accessibility(value: Text("\(date.dayInYear) sur \(date.isYearSextil ? 366 : 365)"))
                Row(value: gregorian, title: "Grégorien :")
                Row(value: date.toShortenedString(), title: "Date abrégée :")
                    .accessibility(value: Text(date.toShortenedString().replacingOccurrences(of: "/", with: "-")))
            }
        }.navigationBarTitle(date.toLongString())
        .navigationBarItems(trailing: Button(action: {
            if favoritesPool.favorites.contains(iso) {
                favoritesPool.favorites.removeAll { date in
                    self.date.date.iso == date
                }
            } else {
                favoritesPool.favorites.append(self.date.date.iso)
            }
            favoritesPool.sync()
        }) {
            let added = favoritesPool.favorites.contains(iso)
            Image(systemName: added ? "star.fill" : "star")
                .accessibility(label: Text(added ? "Retirer des favoris" : "Ajouter aux favoris"))
        }).listNotTooWide()
    }
}

struct DayNameButton: View {
    @State var showDefinePopup: Bool = false
    
    var date: FrenchRepublicanDate
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(spacing: 0) {
                Text(date, format: .republicanDate.day(.dayName))
                    .font(.title)
                DayNameDefiner(showDefinePopup: $showDefinePopup, date: date)
                    .frame(width: 0, height: 0)
            }
            let buttonbar = HStack {
                Button {
                    defineDayName()
                } label: {
                    Image(systemName: "magnifyingglass")
                    Text("Chercher")
                }
                Button {
                    openDayNameDescriptionURL()
                } label: {
                    Image(systemName: "w.circle")
                    Text("Définition en ligne")
                }
            }.tint(Color.purple)
            if #available(iOS 26.0, *) {
                buttonbar
                    .buttonStyle(.glassProminent)
            } else {
                buttonbar
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
            }
        }
    }
    
    func defineDayName() {
        showDefinePopup = true
    }
    
    func openDayNameDescriptionURL() {
        UIApplication.shared.open(date.descriptionURL!)
    }
}

struct DayNameDefiner: UIViewRepresentable {
    typealias UIViewType = UITextView
    
    @Binding var showDefinePopup: Bool
    var date: FrenchRepublicanDate

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.layer.isHidden = true
        tv.text = date.dayName
        tv.isEditable = false // prevents showing the keyboard
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }
    
    func updateUIView(_ tv: UITextView, context: Context) {
        tv.frame = CGRect(x: 0, y: 0, width: tv.superview!.frame.width, height: tv.superview!.frame.height)
        if showDefinePopup {
            DispatchQueue.main.async {
                showDefinePopup = false
                tv.selectAll(tv)
                // hi Apple, please add a public API for this
                let sel = Selector(String(":enifed_".reversed()))
                if tv.responds(to: sel) {
                    tv.perform(sel, with: tv)
                } else {
                    print("cannot define, opening in Safari")
                    UIApplication.shared.open(date.descriptionURL!)
                }
                DispatchQueue.main.async {
                    tv.selectedTextRange = nil
                }
            }
        }
    }
}

struct Row: View {
    var value: String
    var title: String
    
    var body: some View {
        HStack {
            Text(title).lineLimit(1).layoutPriority(2)
                .foregroundColor(.primary)
            Spacer()
            Text(value).layoutPriority(3)
        }
        .accessibilityElement()
        .accessibility(label: Text(title))
        .accessibility(value: Text(value))
    }
}
