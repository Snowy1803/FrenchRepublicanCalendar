//
//  FrenchRepublicanCalendarCalculator.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import Foundation

class FrenchRepublicanDate {
    let MONTH_NAMES = ["Vendémiaire", "Brumaire", "Frimaire", "Nivôse", "Pluviôse", "Ventôse", "Germinal", "Floréal", "Prairial", "Messidor", "Thermidor", "Fructidor", "Sansculottide"]
    let SANSCULOTTIDES = ["Jour de la vertu", "Jour du génie", "Jour du travail", "Jour de l'opinion", "Jour des récompenses", "Jour de la révolution"]

    let MONTH_NAMES_SHORT = ["Vend.r", "Brum.r", "Frim.r", "Niv.ô", "Pluv.ô", "Vent.ô", "Germ.l", "Flo.l", "Prai.l", "Mes.or", "Ther.or", "Fru.or", "Ss"]
    let SANSCULOTTIDES_SHORT = ["Jr vertu", "Jr génie", "Jr travail", "Jr opinion", "Jr récompenses", "Jr révolution"]
    
    let date: Date
    var components: DateComponents!
    
    var dayInYear: Int {
        return (components.month! - 1) * 30 + components.day!
    }
    
    var isYearSextil: Bool {
        return components.year!.isSextil
    }
    
    init(date: Date) {
        self.date = date
        dateToFrenchRepublican()
    }

    /// day of year is 0-indexed
    func simpleGregToRepDate(gregorianYear year: Int) -> Int {
        var dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)! - 265
        if ((year % 100 != 0) && (year % 4 == 0)) || year % 400 == 0 {
            dayOfYear -= 1
        }
        if dayOfYear < 0 {
            dayOfYear += 365
        }
        return dayOfYear
    }

    func dayRemoval(dayOfYear day: inout Int, year: inout Int) {
        day -= 1
        if day == -1 {
            year -= 1
            day = year.isSextil ? 365 : 364
        }
    }

    func dayAdding(dayOfYear day: inout Int, year: inout Int) {
        day += 1
        if day == (year.isSextil ? 366 : 365) {
            year += 1
            day = 0
        }
    }

    func dateToFrenchRepublican() {
        let gregorian = Calendar.current.dateComponents([.year, .month, .day], from: date)
        var year = gregorian.year! - 1792
        if gregorian.month! > 9 || (gregorian.month == 9 && gregorian.day! > ((year + 1).isSextil ? 21 : 21)) {
            year += 1
        }
        var dayOfYear = simpleGregToRepDate(gregorianYear: gregorian.year!)
        if year.isSextil && (gregorian.month! < 9 || (gregorian.month == 9 && gregorian.day! < 22)) {
            dayAdding(dayOfYear: &dayOfYear, year: &year)
        }
        if gregorian.year! >= 1800 {
            dayRemoval(dayOfYear: &dayOfYear, year: &year)
        }
        if gregorian.year! >= 1900 {
            dayRemoval(dayOfYear: &dayOfYear, year: &year)
        }
        if gregorian.year! >= 2100 {
            dayRemoval(dayOfYear: &dayOfYear, year: &year)
        }
        self.components = DateComponents(year: year, month: dayOfYear / 30 + 1, day: dayOfYear % 30 + 1, hour: gregorian.hour, minute: gregorian.minute, second: gregorian.second, nanosecond: gregorian.nanosecond, weekday: dayOfYear % 10 + 1, quarter: dayOfYear / 120 + 1, weekOfMonth: dayOfYear % 30 / 10 + 1, weekOfYear: dayOfYear / 10 + 1, yearForWeekOfYear: year)
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
}

fileprivate extension Int {
    var isSextil: Bool {
        return self % 4 == 0
    }
}
