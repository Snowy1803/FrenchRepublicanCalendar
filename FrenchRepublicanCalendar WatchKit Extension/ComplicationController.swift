//
//  ComplicationController.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import ClockKit


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
        handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: getTimelineEntry(family: complication.family, date: Date())))
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var entries = [CLKComplicationTimelineEntry]()
        entries.reserveCapacity(limit)
        let midnight = Calendar.current.startOfDay(for: Date())
        for day in 0..<limit {
            let date = midnight.addingTimeInterval(TimeInterval(3600 * 24 * day))
            entries.append(CLKComplicationTimelineEntry(date: date, complicationTemplate: getTimelineEntry(family: complication.family, date: date)))
        }
        handler(entries)
    }
    
    func getTimelineEntry(family: CLKComplicationFamily, date: Date) -> CLKComplicationTemplate {
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
            template.line1TextProvider = CLKSimpleTextProvider(text: frd.toShortString())
            template.line2TextProvider = CLKSimpleTextProvider(text: "An \(frd.components.year!)")
            return template
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            template.textProvider = CLKSimpleTextProvider(text: frd.toLongString())
            let smaller = CLKComplicationTemplateGraphicCircularStackText()
            smaller.line1TextProvider = CLKSimpleTextProvider(text: "\(frd.components.day!)")
            smaller.line2TextProvider = CLKSimpleTextProvider(text: "\(frd.components.month!)")
            template.circularTemplate = smaller
            return template
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.outerTextProvider = CLKSimpleTextProvider(text: "\(frd.components.day!)")
            template.innerTextProvider = CLKSimpleTextProvider(text: "\(frd.monthName) \(frd.components.year!)")
            return template
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "\(frd.toLongStringNoYear())")
            template.body1TextProvider = CLKSimpleTextProvider(text: frd.components.month! == 13 ? "\(frd.weekdayName)" : "\(frd.weekdayName) \(frd.dayName)", shortText: frd.dayName)
            template.body2TextProvider = CLKSimpleTextProvider(text: "An \(frd.components.year!)")
            return template
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "\(frd.toLongStringNoYear())")
            template.body1TextProvider = CLKSimpleTextProvider(text: frd.components.month! == 13 ? "\(frd.weekdayName)" : "\(frd.weekdayName) \(frd.dayName)", shortText: frd.dayName)
            template.body2TextProvider = CLKSimpleTextProvider(text: "An \(frd.components.year!)")
            return template
        default:
            fatalError("Family not handled")
        }
        
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(getTimelineEntry(family: complication.family, date: FrenchRepublicanDate.ORIGIN))
    }
    
}
