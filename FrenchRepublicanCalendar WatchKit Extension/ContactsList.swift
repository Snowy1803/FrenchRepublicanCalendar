//
//  ContactsList.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil Pedersen on 20/04/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import SwiftUI
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
                    NavigationLink(destination: ContactDetails(contact: c)) {
                        self.imageOf(data: c.thumbnailImageData)
                        Text(CNContactFormatter.attributedString(from: c, style: .fullName)?.string ?? "-")
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
}

struct ContactDetails: View {
    var contact: CNContact
    
    var body: some View {
        List {
            if contact.birthday != nil {
                Section(header: Text("Anniversaire")) {
                    DateRow(date: contact.birthday!.date!, frd: FrenchRepublicanDate(date: contact.birthday!.date!))
                }
            }
            if !contact.dates.isEmpty {
                Section(header: Text("Dates")) {
                    ForEach(contact.dates, id: \.self) { d in
                        DateRow(date: d.value.date!, frd: FrenchRepublicanDate(date: d.value.date!), desc: d.label)
                    }
                }
            }
        }.navigationBarTitle(contact.givenName)
    }
}

struct DateRow: View {
    var date: Date
    var frd: FrenchRepublicanDate
    var desc: String?
    
    var human: String {
        let df = DateFormatter()
        df.dateFormat = "d MMMM yyyy"
        return df.string(from: date)
    }
    
    var body: some View {
        NavigationLink(destination: DateDetails(components: date.toMyDateComponents, date: frd)) {
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

struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        ContactsList()
    }
}
