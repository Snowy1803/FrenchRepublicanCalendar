//
//  ComplicationController.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import ClockKit
import FrenchRepublicanCalendarCore

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date(timeIntervalSince1970: 0))
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date().addingTimeInterval(3600 * 24 * 365))
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        if let entry = (complication.isDecimalTime ? getDecimalTimeEntry : getTimelineEntry)(complication.family, Date()) {
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: entry))
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var entries = [CLKComplicationTimelineEntry]()
        entries.reserveCapacity(limit)
        if complication.isDecimalTime {
            let startOfDay = Calendar.gregorian.startOfDay(for: date)
            var current = DecimalTime(timeSinceMidnight: date.timeIntervalSince(startOfDay))
            current.minute += 1
            current.second = 0
            current.remainder = 0
            let dtime = current.decimalTime
            let day = dtime > 10_00_00
            current.decimalTime = day ? dtime - 10_00_00 : dtime
            var date = startOfDay + current.timeSinceMidnight
            if day {
                date = Calendar.gregorian.date(byAdding: .day, value: 1, to: date)!
            }
            current.decimalTime += 50 * DecimalTime.decimalSecond // avoids rounding errors
            for _ in 0..<limit {
                guard let entry = getDecimalTimeEntry(family: complication.family, time: current) else {
                    handler(nil)
                    return
                }
                entries.append(CLKComplicationTimelineEntry(date: date, complicationTemplate: entry))
                current.decimalTime += 100 * DecimalTime.decimalSecond
                date += 100 * DecimalTime.decimalSecond
            }
        } else {
            let midnight = Calendar.gregorian.startOfDay(for: Date())
            for day in 0..<limit {
                let date = Calendar.gregorian.date(byAdding: .day, value: day, to: midnight)!
                guard let entry = getTimelineEntry(family: complication.family, date: date) else {
                    handler(nil)
                    return
                }
                entries.append(CLKComplicationTimelineEntry(date: date, complicationTemplate: entry))
            }
        }
        handler(entries)
    }
    
    func getTimelineEntry(family: CLKComplicationFamily, date: Date) -> CLKComplicationTemplate? {
        let frd = FrenchRepublicanDate(date: date)
        switch (family) {
        case .utilitarianSmall, .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: frd.toShortString())
            return template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: frd.toLongString(), shortText: frd.toLongStringNoYear())
            return template
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: String(frd.components.day!))
            template.line2TextProvider = CLKSimpleTextProvider(text: frd.shortMonthName)
            return template
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            template.textProvider = CLKSimpleTextProvider(text: frd.toLongString())
            let smaller = CLKComplicationTemplateGraphicCircularStackText()
            smaller.line1TextProvider = CLKSimpleTextProvider(text: String(frd.components.day!))
            smaller.line2TextProvider = CLKSimpleTextProvider(text: frd.shortMonthName)
            template.circularTemplate = smaller
            return template
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.outerTextProvider = CLKSimpleTextProvider(text: String(frd.components.day!))
            template.innerTextProvider = CLKSimpleTextProvider(text: "\(frd.monthName) \(frd.components.year!)")
            return template
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: frd.toLongStringNoYear())
            template.body1TextProvider = CLKSimpleTextProvider(text: frd.components.month! == 13 ? frd.weekdayName : "\(frd.weekdayName) \(frd.dayName)", shortText: frd.dayName)
            template.body2TextProvider = CLKSimpleTextProvider(text: "An \(frd.formattedYear)")
            return template
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: frd.toLongStringNoYear())
            template.body1TextProvider = CLKSimpleTextProvider(text: frd.components.month! == 13 ? frd.weekdayName : "\(frd.weekdayName) \(frd.dayName)", shortText: frd.dayName)
            template.body2TextProvider = CLKSimpleTextProvider(text: "An \(frd.formattedYear)")
            return template
        default:
            print("Family not handled: \(family.rawValue)")
            return nil
        }
    }
    
    func getDecimalTimeEntry(family: CLKComplicationFamily, date: Date) -> CLKComplicationTemplate? {
        let time = DecimalTime(timeSinceMidnight: date.timeIntervalSince(Calendar.gregorian.startOfDay(for: date)))
        return getDecimalTimeEntry(family: family, time: time)
    }
    
    func getDecimalTimeEntry(family: CLKComplicationFamily, time: DecimalTime) -> CLKComplicationTemplate? {
        switch (family) {
        case .utilitarianSmall, .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: time.shortDescription)
            return template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: time.shortDescription)
            return template
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: time.shortDescription)
            return template
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.outerTextProvider = CLKSimpleTextProvider(text: "")
            template.innerTextProvider = CLKSimpleTextProvider(text: time.shortDescription)
            return template
        default:
            print("Family not handled: \(family.rawValue)")
            return nil
        }
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        if complication.isDecimalTime {
            handler(getDecimalTimeEntry(family: complication.family, time: DecimalTime(hour: 4, minute: 29, second: 0, remainder: 0)))
        } else {
            handler(getTimelineEntry(family: complication.family, date: FrenchRepublicanDate.origin))
        }
    }
    
    // MARK: - watchOS 7
    
    @available(watchOS 7.0, *)
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        handler([CLKComplicationDescriptor(identifier: "CurrentFRDate", displayName: "Aujourd'hui", supportedFamilies: [.utilitarianSmall, .utilitarianSmallFlat, .utilitarianLarge, .extraLarge, .graphicBezel, .graphicCorner, .graphicRectangular, .modularLarge]), CLKComplicationDescriptor(identifier: "CurrentDecimalTime", displayName: "Temps Décimal", supportedFamilies: [.utilitarianSmall, .utilitarianSmallFlat, .utilitarianLarge, .extraLarge, .graphicCorner])])
    }
}

extension CLKComplication {
    var isDecimalTime: Bool {
        if #available(watchOS 7.0, *) {
            return identifier == "CurrentDecimalTime"
        } else {
            return false
        }
    }
}

extension DecimalTime {
    var shortDescription: String {
        "\(hour):\(("0" + String(minute)).suffix(2))"
    }
}
