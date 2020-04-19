//
//  FrenchRepublicanCalendarCalculator.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import Foundation

struct FrenchRepublicanDate: CustomDebugStringConvertible {
    let MONTH_NAMES = ["Vendémiaire", "Brumaire", "Frimaire", "Nivôse", "Pluviôse", "Ventôse", "Germinal", "Floréal", "Prairial", "Messidor", "Thermidor", "Fructidor", "Sansculottide"]
    let SANSCULOTTIDES = ["Jour de la vertu", "Jour du génie", "Jour du travail", "Jour de l'opinion", "Jour des récompenses", "Jour de la révolution"]

    let MONTH_NAMES_SHORT = ["Vend.r", "Brum.r", "Frim.r", "Niv.ô", "Pluv.ô", "Vent.ô", "Germ.l", "Flo.l", "Prai.l", "Mes.or", "Ther.or", "Fru.or", "Ss"]
    let SANSCULOTTIDES_SHORT = ["Jr vertu", "Jr génie", "Jr travail", "Jr opinion", "Jr récompenses", "Jr révolution"]
    
    let WEEKDAYS = ["Primidi", "Duodi", "Tridi", "Quartidi", "Quintidi", "Sextidi", "Septidi", "Octidi", "Nonidi", "Décadi"]
    
    /// the Date this object was initialized with
    let date: Date
    
    /// `year`: The year, starting at 1 for 1792-09-22,
    ///
    /// month: The month, 1-13 (13 being the additional days, called SANSCULOTTIDES),
    ///
    /// day: The day in the month 1-30 (1-5 or 1-6 for the 13th month, depending on .isYearSextil),
    ///
    /// hour, minute, second, nanosecond: The same as in the gregorian calendar,
    ///
    /// weekday: The weekday 1-10,
    ///
    /// quarter: The season, 1-5 (1=winter, 2=spring, 3=summer, 4=autumn, 5=SANSCULOTTIDES),
    ///
    /// weekOfMonth: The week within the month (a week being 10 days),
    ///
    /// weekOfYear: The week within the year (a week being 10 days)
    var components: DateComponents!
    
    /// The day in year date component, 1-indexed
    var dayInYear: Int {
        return (components.month! - 1) * 30 + components.day!
    }
    
    /// true if the current Republican year is sextil, false otherwise
    var isYearSextil: Bool {
        return components.year!.isSextil
    }
    
    init(date: Date) {
        self.date = date
        dateToFrenchRepublican()
    }

    /// calculates a  0-indexed day of year out of self.date, without the correction algorithms.
    private func simpleGregToRepDate(gregorianYear year: Int) -> Int {
        var dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)! - 265
        if ((year % 100 != 0) && (year % 4 == 0)) || year % 400 == 0 {
            dayOfYear -= 1
        }
        if dayOfYear < 0 {
            dayOfYear += 365
        }
        return dayOfYear
    }

    private func dayRemoval(dayOfYear day: inout Int, year: inout Int) {
        day -= 1
        if day == -1 {
            year -= 1
            day = year.isSextil ? 365 : 364
        }
    }

    private func dayAdding(dayOfYear day: inout Int, year: inout Int) {
        day += 1
        if day == (year.isSextil ? 366 : 365) {
            year += 1
            day = 0
        }
    }

    private mutating func dateToFrenchRepublican() {
        let gregorian = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
        var year = gregorian.year! - 1792
        if gregorian.month! > 9 || (gregorian.month == 9 && gregorian.day! > ((year + 1).isSextil ? 21 : 21)) {
            year += 1
        }
        var dayOfYear = simpleGregToRepDate(gregorianYear: gregorian.year!)
        if year.isSextil && (gregorian.month! < 9 || (gregorian.month == 9 && gregorian.day! < 22)) {
            dayAdding(dayOfYear: &dayOfYear, year: &year)
        }
        var y = 1800
        while gregorian.year! >= y {
            dayRemoval(dayOfYear: &dayOfYear, year: &year)
            y += 100
            if y % 400 == 0 {
                y += 100
            }
        }
        self.components = DateComponents(year: year, month: dayOfYear / 30 + 1, day: dayOfYear % 30 + 1, hour: gregorian.hour, minute: gregorian.minute, second: gregorian.second, nanosecond: gregorian.nanosecond, weekday: dayOfYear % 10 + 1, quarter: dayOfYear / 120 + 1, weekOfMonth: dayOfYear % 30 / 10 + 1, weekOfYear: dayOfYear / 10 + 1, yearForWeekOfYear: year)
    }

    func toVeryLongString() -> String {
        if components.month == 13 {
            return toLongString()
        }
        return "\(WEEKDAYS[components.weekday! - 1]) \(toLongString())"
    }

    func toLongString() -> String {
        if components.month == 13 {
            return "\(SANSCULOTTIDES[components.day! - 1]) An \(components.year!)"
        }
        return "\(components.day!) \(MONTH_NAMES[components.month! - 1]) An \(components.year!)"
    }

    func toShortString() -> String {
        if components.month == 13 {
            return "\(SANSCULOTTIDES_SHORT[components.day! - 1])"
        }
        return "\(components.day!) \(MONTH_NAMES_SHORT[components.month! - 1])"
    }
    
    var debugDescription: String {
        return "\(toVeryLongString()), quarter \(components.quarter!), decade \(components.weekOfMonth!) of month, decade \(components.weekOfYear!) of year, day \(dayInYear) of year"
    }
}

fileprivate extension Int {
    var isSextil: Bool {
        return self % 4 == 0
    }
}
