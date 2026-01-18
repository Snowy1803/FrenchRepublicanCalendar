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
import UIKit

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
    
    func groupedCalendars(editableCalendarsOnly: Bool) -> [SourceStore] {
        store.sources.map { source in
            SourceStore(
                id: source.sourceIdentifier,
                type: sourceType(source: source),
                title: localizedTitle(source: source),
                content: source.calendars(for: .event).filter { calendar in
                    !editableCalendarsOnly || calendar.allowsContentModifications
                }.sorted { lhs, rhs in
                    lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
                }
            )
        }.filter {
            !$0.content.isEmpty
        }.sorted()
    }
    
    func sourceType(source: EKSource) -> SourceStore.SourceType {
        if source.sourceType == .birthdays {
            return .other
        } else if source.sourceType == .subscribed {
            return .subscribed
        } else {
            return .regular
        }
    }
    
    func localizedTitle(source: EKSource) -> String {
        if source.sourceType == .birthdays {
            return "Autres"
        } else if source.sourceType == .subscribed {
            return "Abonnements"
        } else if source.sourceType == .local && source.title == "Default" {
            return "Sur mon \(UIDevice.current.localizedModel)"
        } else {
            return source.title
        }
    }
}

struct SourceStore: Hashable, Identifiable {
    var id: String
    var type: SourceType
    var title: String
    var content: [EKCalendar]
    
    enum SourceType: Comparable {
        case regular
        case subscribed
        case other
    }
}

extension SourceStore: Comparable {
    static func < (lhs: SourceStore, rhs: SourceStore) -> Bool {
        if lhs.type == rhs.type {
            return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
        }
        return lhs.type < rhs.type
    }
}
