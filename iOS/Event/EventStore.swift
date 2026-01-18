//
//  EventStore.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 16/01/2026.
//  Copyright © 2026 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import EventKit

class EventStore: ObservableObject {
    var store: EKEventStore
    
    var subscription: AnyCancellable?
    
    init(store: EKEventStore) {
        self.store = store
        subscription = NotificationCenter.default.publisher(for: .EKEventStoreChanged, object: store).sink { [unowned self] notif in
            self.objectWillChange.send()
        }
    }
    
    func shouldShow(calendar: EKCalendar) -> Bool {
        let filtered = UserDefaults.standard.stringArray(forKey: "filteredCalendars") ?? []
        return !filtered.contains(where: { $0 == calendar.calendarIdentifier })
    }
    
    func setFiltered(calendar: EKCalendar, show: Bool) {
        objectWillChange.send()
        var filtered = UserDefaults.standard.stringArray(forKey: "filteredCalendars") ?? []
        filtered.removeAll(where: { $0 == calendar.calendarIdentifier })
        if !show {
            filtered.append(calendar.calendarIdentifier)
        }
        UserDefaults.standard.set(filtered, forKey: "filteredCalendars")
    }
    
    func groupedCalendars(editableCalendarsOnly: Bool) -> [(EKSource, [EKCalendar])] {
        store.sources.map { source in
            (source, source.calendars(for: .event).filter { calendar in
                !editableCalendarsOnly || calendar.allowsContentModifications
            }.sorted { lhs, rhs in
                lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
            })
        }.filter {
            !$0.1.isEmpty
        }.sorted { lhs, rhs in
            lhs.0.title.localizedStandardCompare(rhs.0.title) == .orderedAscending
        }
    }
}
