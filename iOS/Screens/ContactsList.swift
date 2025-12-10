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
    @State var contacts = [CNContact]()
    @State var errorMessage: String = "Chargement"

    nonisolated func fetchContacts() {
        let store = CNContactStore()
        
        var contacts: [CNContact] = []
        var errorMessage: String = "Aucun contact"
        
        var keys = [CNContactThumbnailImageDataKey, CNContactBirthdayKey, CNContactDatesKey] as [CNKeyDescriptor]
        keys.append(CNContactFormatter.descriptorForRequiredKeys(for: .fullName))
        let request = CNContactFetchRequest(keysToFetch: keys)

        do {
            try store.enumerateContacts(with: request) { (contact, stop) in
                if contact.birthday != nil || !contact.dates.isEmpty {
                    contacts.append(contact)
                } else {
                    errorMessage = "Aucun contact avec un anniversaire"
                }
            }
            Task { @MainActor in
                contacts.sort(by: { c1, c2 in self.stringOf(contact: c1) < self.stringOf(contact: c2) })
                self.contacts = contacts
                self.errorMessage = errorMessage
            }
        }
        catch {
            print("Failed to fetch contact, error: \(error)")
            Task { @MainActor in
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    var body: some View {
        Group {
            if contacts.isEmpty {
                if CNContactStore.authorizationStatus(for: .contacts) == .denied {
                    VStack {
                        Text("Accès refusé")
                            .font(.title)
                            .padding(.bottom)
                        Text("Autorisez l'accès aux Contacts dans les Réglages iOS")
                            .padding(.bottom, 100)
                    }.multilineTextAlignment(.center)
                } else {
                    Text(self.errorMessage)
                        .multilineTextAlignment(.center)
                }
            } else {
                List(contacts, id: \.identifier) { c in
                    NavigationLink(destination: ContactDetails(contact: c)) {
                        self.imageOf(data: c.thumbnailImageData)
                        Text(self.stringOf(contact: c))
                    }
                }
                #if !os(watchOS)
                .listNotTooWide()
                #endif
            }
        }.onAppear {
            Task.detached {
                self.fetchContacts()
            }
        }.navigationBarTitle("Contacts")
    }
    
    @ViewBuilder func imageOf(data: Data?) -> some View {
        if let imgData = data,
            let img = UIImage(data: imgData) {
            Image(uiImage: img)
                .resizable()
                .frame(width: 20, height: 20)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    func stringOf(contact: CNContact) -> String {
        CNContactFormatter.attributedString(from: contact, style: .fullName)?.string ?? "-"
    }
}

struct ContactDetails: View {
    @EnvironmentObject var midnight: Midnight
    var contact: CNContact
    
    var body: some View {
        Form {
            if contact.birthday != nil {
                BirthdaySection(dateComponents: contact.birthday!)
            }
            if !contact.dates.isEmpty {
                Section(header: Text("Dates")) {
                    ForEach(contact.dates, id: \.identifier) { d in
                        if let date = d.value.date {
                            let label = d.label == "_$!<Anniversary>!$_" ? "Fête" : d.label
                            DateRow(frd: FrenchRepublicanDate(date: date), desc: label)
                                .accessibility(label: Text(label ?? ""))
                        }
                    }
                }
            }
        }.navigationBarTitle(contact.givenName)
        #if !os(watchOS)
        .listNotTooWide()
        #endif
    }
}

struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        ContactsList()
    }
}

struct BirthdaySection: View {
    var dateComponents: DateComponents
    
    var body: some View {
        Section {
            if dateComponents.year != nil {
                let birthday = FrenchRepublicanDate(date: dateComponents.date!)
                DateRow(frd: birthday)
                    .accessibility(label: Text("Anniversaire"))
                let next = birthday.nextAnniversary
                let age = next.components.year! - birthday.components.year!
                DateRow(frd: next, desc: "🎂 \(age) ans")
                    .accessibility(label: Text("Anniversaire des \(age) ans"))
            } else if let nextYear = Calendar.gregorian.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) {
                // No year specified, use next occurrence
                DateRow(frd: FrenchRepublicanDate(date: nextYear))
                    .accessibility(label: Text("Anniversaire"))
            }
        } header: {
            Text("Anniversaire")
        } footer: {
            if dateComponents.year != nil {
                Text("Ceci représente l'anniversaire républicain de ce contact")
            } else {
                Text("Ceci représente l'anniversaire grégorien de ce contact, car l'année de naissance n'a pas été renseignée")
            }
        }
    }
}

extension FrenchRepublicanDate {
    var nextAnniversary: FrenchRepublicanDate {
        var curr = self
        var age = 0
        while curr.date < Date() && !Calendar.gregorian.isDateInToday(curr.date) {
            curr = .init(dayInYear: self.dayInYear, year: self.year + age)
            age += 1
        }
        return curr
    }
}
