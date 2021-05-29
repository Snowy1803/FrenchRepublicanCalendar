//
//  ContactsList.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil Pedersen on 20/04/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI
import FrenchRepublicanCalendarCore
import Contacts

struct ContactsList: View {
    
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
                VStack {
                    Text("Accès refusé")
                        .font(.title)
                        .padding(.bottom)
                    Text("Autorisez l'accès aux Contacts dans les Réglages iOS")
                        .padding(.bottom, 100)
                }.multilineTextAlignment(.center)
            } else {
                List(contacts, id: \.identifier) { c in
                    NavigationLink(destination: ContactDetails(contact: c)) {
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
    @EnvironmentObject var midnight: Midnight
    var contact: CNContact
    
    var body: some View {
        Form {
            if contact.birthday != nil {
                Section(header: Text("Anniversaire")) {
                    BirthdaySection(birthday: FrenchRepublicanDate(date: contact.birthday!.date!))
                }
            }
            if !contact.dates.isEmpty {
                Section(header: Text("Dates")) {
                    ForEach(contact.dates, id: \.self) { d in
                        if let date = d.value.date {
                            let label = d.label == "_$!<Anniversary>!$_" ? "Fête" : d.label
                            DateRow(frd: FrenchRepublicanDate(date: date), desc: label)
                                .accessibility(label: Text(label ?? ""))
                        }
                    }
                }
            }
        }.navigationBarTitle(contact.givenName)
    }
}

struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        ContactsList()
    }
}

struct BirthdaySection: View {
    var birthday: FrenchRepublicanDate
    
    var body: some View {
        Group {
            DateRow(frd: birthday)
                .accessibility(label: Text("Anniversaire"))
            let age = birthday.nextAnniversary.components.year! - birthday.components.year!
            DateRow(frd: birthday.nextAnniversary, desc: "🎂 \(age) ans")
                .accessibility(label: Text("Anniversaire des \(age) ans"))
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
