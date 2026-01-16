//
//  EventModel.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 15/01/2026.
//  Copyright © 2026 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import FrenchRepublicanCalendarCore
import EventKit
import Combine

class EventModel: ObservableObject {
    @EventProp var title: String = ""
    @EventProp var location: String = ""
    @EventProp var isAllDay: Bool = false
    @EventProp var startDate: Date
    @EventProp var endDate: Date
    @EventProp var travelTime: DecimalTime = .midnight
    @EventProp var recurrence: Int? = nil
    @EventProp var recurrenceEnd: Date? = nil
    @EventProp var calendar: EKCalendar? = nil
    @EventProp var url: String = ""
    @EventProp var notes: String = ""
    @EventProp var alarms: [TimeInterval] = []
    
    var store: EventStore
    var event: EKEvent?
    
    init(store: EventStore, date: FrenchRepublicanDate) {
        self.startDate = date.date.addingTimeInterval(DecimalTime(hour: 4, minute: 0, second: 0, remainder: 0).timeSinceMidnight)
        self.endDate = date.date.addingTimeInterval(DecimalTime(hour: 4, minute: 50, second: 0, remainder: 0).timeSinceMidnight)
        self._startDate.changed = true
        self._endDate.changed = true
        self.store = store
        self.event = nil
    }
    
    init(store: EventStore, event: EKEvent) {
        self.title = event.title
        assert(_title.changed == false)
        self.location = event.location ?? ""
        self.isAllDay = event.isAllDay
        self.startDate = event.startDate
        self.endDate = event.endDate
        if let travelTimeValue = event.value(forKey: "travelTime") as? Int {
            self.travelTime = DecimalTime(timeSinceMidnight: TimeInterval(travelTimeValue))
        }
        if let recurrenceRule = event.recurrenceRules?.first {
            self.recurrence = recurrenceRule.interval
            if let recurrenceEnd = recurrenceRule.recurrenceEnd?.endDate {
                self.recurrenceEnd = recurrenceEnd
            }
        }
        self.calendar = event.calendar
        self.url = event.url?.absoluteString ?? ""
        self.notes = event.notes ?? ""
        if let eventAlarms = event.alarms {
            self.alarms = eventAlarms.map { -$0.relativeOffset }
        }
        self.store = store
        self.event = event
    }
    
    // Apply local changes to backing EKEvent, without saving
    func applyChanges() {
        guard let event else {
            preconditionFailure()
        }
        if _title.changed {
            event.title = title
        }
        if _location.changed {
            event.location = location.isEmpty ? nil : location
        }
        if _startDate.changed {
            event.startDate = startDate
        }
        if _endDate.changed {
            event.endDate = endDate
        }
        if _isAllDay.changed {
            event.isAllDay = isAllDay
        }
        if _calendar.changed || event.calendar == nil {
            event.calendar = calendar ?? store.store.defaultCalendarForNewEvents
        }
        if _travelTime.changed && !isAllDay {
            event.setValue(Int(travelTime.timeSinceMidnight), forKey: "travelTime")
        }
        if _recurrence.changed || _recurrenceEnd.changed {
            event.recurrenceRules = []
            if let recurrence {
                event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .daily, interval: recurrence, end: recurrenceEnd.flatMap { EKRecurrenceEnd(end: $0)} ))
            }
        }
        if _url.changed {
            event.url = url.isEmpty ? nil : URL(string: url)
        }
        if _notes.changed {
            event.notes = notes.isEmpty ? nil : notes
        }
        if _alarms.changed {
            event.alarms = []
            for alarm in alarms {
                event.addAlarm(EKAlarm(relativeOffset: -alarm))
            }
        }
    }
    
    // Refresh locally cached values from a given EKEvent
    func refreshUnchanged() {
        guard let event else {
            preconditionFailure()
        }
        objectWillChange.send()
        self._title.backingValue = event.title
        self._location.backingValue = event.location ?? ""
        self._isAllDay.backingValue = event.isAllDay
        self._startDate.backingValue = event.startDate
        self._endDate.backingValue = event.endDate
        if let travelTimeValue = event.value(forKey: "travelTime") as? Int {
            self._travelTime.backingValue = DecimalTime(timeSinceMidnight: TimeInterval(travelTimeValue))
        } else {
            self._travelTime.backingValue = .midnight
        }
        if let recurrenceRule = event.recurrenceRules?.first {
            self._recurrence.backingValue = recurrenceRule.interval
            if let recurrenceEnd = recurrenceRule.recurrenceEnd?.endDate {
                self._recurrenceEnd.backingValue = recurrenceEnd
            } else {
                self._recurrenceEnd.backingValue = nil
            }
        } else {
            self._recurrence.backingValue = nil
            self._recurrenceEnd.backingValue = nil
        }
        self._calendar.backingValue = event.calendar
        self._url.backingValue = event.url?.absoluteString ?? ""
        self._notes.backingValue = event.notes ?? ""
        if let eventAlarms = event.alarms {
            self._alarms.backingValue = eventAlarms.map { -$0.relativeOffset }
        } else {
            self._alarms.backingValue = []
        }
        
    }
    
    func createNewEvent() {
        assert(self.event == nil)
        self.event = EKEvent(eventStore: store.store)
        applyChanges()
        try? store.store.save(self.event!, span: .thisEvent)
    }
    
    func saveChanges(span: EKSpan) {
        applyChanges()
        try? store.store.save(event!, span: span)
    }
}

extension EventModel: Identifiable {
    var id: String {
        self.event?.calendarItemIdentifier ?? ""
    }
}

@propertyWrapper struct EventProp<WrappedValue> {
    var value: WrappedValue
    var changed: Bool = false
    
    @available(*, unavailable, message: "Only classes supported")
    var wrappedValue: WrappedValue {
        get { fatalError() }
        set { fatalError() }
    }

    var backingValue: WrappedValue {
        get { value }
        set {
            if !changed {
                value = newValue
            }
        }
    }
    
    init(wrappedValue value: WrappedValue) {
        self.value = value
    }
    
    public static subscript<EnclosingSelf>(_enclosingInstance object: EnclosingSelf, wrapped wrappedKeyPath: Swift.ReferenceWritableKeyPath<EnclosingSelf, WrappedValue>, storage storageKeyPath: Swift.ReferenceWritableKeyPath<EnclosingSelf, Self>) -> WrappedValue where EnclosingSelf : ObservableObject, EnclosingSelf.ObjectWillChangePublisher == ObservableObjectPublisher {
        get { object[keyPath: storageKeyPath].value }
        set {
            object.objectWillChange.send()
            object[keyPath: storageKeyPath].changed = true
            object[keyPath: storageKeyPath].value = newValue
        }
    }
}
