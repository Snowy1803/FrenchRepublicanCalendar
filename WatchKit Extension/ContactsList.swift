//
//  ContactsList.swift
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
import Contacts

struct ContactsList: View {
    @ObservedObject var favoritesPool: FavoritesPool
    
    @State var contacts = [CNContact]()
    
    func fetchContacts() {
        let store = CNContactStore()
        
        contacts.removeAll()
        
        var keys = [CNContactThumbnailImageDataKey, CNContactBirthdayKey, CNContactDatesKey] as [CNKeyDescriptor]
        keys.append(CNContactFormatter.descriptorForRequiredKeys(for: .fullName))
        let request = CNContactFetchRequest(keysToFetch: keys)

        do {
            try store.enumerateContacts(with: request) { (contact, stop) in
                if contact.birthday != nil || !contact.dates.isEmpty {
                    self.contacts.append(contact)
                }
            }
            contacts.sort(by: { c1, c2 in self.stringOf(contact: c1) < self.stringOf(contact: c2) })
        }
        catch {
            print("Failed to fetch contact, error: \(error)")
        }
    }
    
    var body: some View {
        Group {
            if contacts.isEmpty {
                Text("Accès refusé")
            } else {
                List(contacts, id: \.identifier) { c in
                    NavigationLink(destination: ContactDetails(favoritesPool: favoritesPool, contact: c)) {
                        self.imageOf(data: c.thumbnailImageData)
                        Text(self.stringOf(contact: c))
                    }
                }
            }
        }.onAppear {
            self.fetchContacts()
        }.navigationBarTitle("Contacts")
    }
    
    func imageOf(data: Data?) -> AnyView {
        if let imgData = data,
            let img = UIImage(data: imgData) {
            return AnyView(Image(uiImage: img).resizable().frame(width: 20, height: 20).clipShape(Circle()))
        }
        return AnyView(Image(systemName: "person.circle").resizable().frame(width: 20, height: 20))
    }
    
    func stringOf(contact: CNContact) -> String {
        CNContactFormatter.attributedString(from: contact, style: .fullName)?.string ?? "-"
    }
}

struct ContactDetails: View {
    @ObservedObject var favoritesPool: FavoritesPool
    var contact: CNContact
    
    var body: some View {
        List {
            if contact.birthday != nil {
                Section(header: Text("Anniversaire")) {
                    BirthdaySection(favoritesPool: favoritesPool, birthday: FrenchRepublicanDate(date: contact.birthday!.date!))
                }
            }
            if !contact.dates.isEmpty {
                Section(header: Text("Dates")) {
                    ForEach(contact.dates, id: \.self) { d in
                        if let date = d.value.date {
                            DateRow(favoritesPool: favoritesPool, frd: FrenchRepublicanDate(date: date), desc: d.label == "_$!<Anniversary>!$_" ? "Fête" : d.label)
                        }
                    }
                }
            }
        }.navigationBarTitle(contact.givenName)
    }
}

struct DateRow: View {
    @ObservedObject var favoritesPool: FavoritesPool
    var frd: FrenchRepublicanDate
    var desc: String?
    
    var human: String {
        if Calendar.gregorian.isDateInToday(frd.date) {
            return "Aujourd'hui"
        }
        let df = DateFormatter()
        df.dateFormat = "d MMMM yyyy"
        return df.string(from: frd.date)
    }
    
    var body: some View {
        NavigationLink(destination: DateDetails(favoritesPool: favoritesPool, components: frd.date.toMyDateComponents, date: frd)) {
            VStack(alignment: .leading) {
                HStack {
                    Text(frd.toLongStringNoYear())
                    Spacer()
                    Text("\(frd.components.year!)")
                }
                Text(human).foregroundColor(.secondary)
                if desc != nil {
                    Text(desc!)
                }
            }.padding([.top, .bottom], 2)
        }
    }
}

struct BirthdaySection: View {
    @ObservedObject var favoritesPool: FavoritesPool
    var birthday: FrenchRepublicanDate
    
    var body: some View {
        Group {
            DateRow(favoritesPool: favoritesPool, frd: birthday)
            DateRow(favoritesPool: favoritesPool, frd: birthday.nextAnniversary, desc: "🎂 \(birthday.nextAnniversary.components.year! - birthday.components.year!) ans")
        }
    }
}

extension FrenchRepublicanDate {
    var nextAnniversary: FrenchRepublicanDate {
        var curr = self
        while curr.date < Date() && !Calendar.gregorian.isDateInToday(curr.date) {
            curr.nextYear()
        }
        return curr
    }
}
