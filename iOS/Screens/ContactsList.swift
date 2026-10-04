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

struct ContactItem: Identifiable, @unchecked Sendable {
    var id: String { contact.identifier }
    let contact: CNContact
    let displayName: String
    let thumbnailImage: UIImage?
}

struct ContactsList: View {
    @State var contacts = [ContactItem]()
    @State var errorMessage: String = "Chargement"

    func fetchContacts() async {
        let (items, message) = await Task.detached(priority: .userInitiated) { () -> ([ContactItem], String) in
            let store = CNContactStore()
            var matchingContacts: [CNContact] = []
            var errMessage: String = "Aucun contact"

            var keys = [CNContactThumbnailImageDataKey, CNContactBirthdayKey, CNContactDatesKey] as [CNKeyDescriptor]
            keys.append(CNContactFormatter.descriptorForRequiredKeys(for: .fullName))
            let request = CNContactFetchRequest(keysToFetch: keys)

            do {
                try store.enumerateContacts(with: request) { (contact, stop) in
                    if contact.birthday != nil || !contact.dates.isEmpty {
                        matchingContacts.append(contact)
                    } else {
                        errMessage = "Aucun contact avec un anniversaire"
                    }
                }
                let formatter = CNContactFormatter()
                let items: [ContactItem] = matchingContacts.map { contact in
                    let name = formatter.string(from: contact) ?? "-"
                    let image = contact.thumbnailImageData.flatMap { UIImage(data: $0) }
                    return ContactItem(contact: contact, displayName: name, thumbnailImage: image)
                }.sorted {
                    $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending
                }
                return (items, errMessage)
            } catch {
                print("Failed to fetch contact, error: \(error)")
                return ([], error.localizedDescription)
            }
        }.value

        guard !Task.isCancelled else { return }
        self.contacts = items
        self.errorMessage = message
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
                List(contacts) { c in
                    NavigationLink(destination: ContactDetails(contact: c.contact)) {
                        self.imageOf(item: c)
                        Text(c.displayName)
                    }
                }
                #if !os(watchOS)
                .listNotTooWide()
                #endif
            }
        }.task {
            await fetchContacts()
        }.navigationBarTitle("Contacts")
    }
    
    @ViewBuilder func imageOf(item: ContactItem) -> some View {
        if let img = item.thumbnailImage {
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
