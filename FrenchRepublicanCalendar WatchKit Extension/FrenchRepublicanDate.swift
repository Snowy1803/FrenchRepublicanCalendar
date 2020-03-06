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
    
    init(date: Date) {
        self.date = date
        self.components = dateToFrenchRepublican()
    }

    func simpleGregToRepDate() -> (Int, Int) {
        var dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)! - 265
        if dayOfYear < 0 {
            dayOfYear += 365
        }
        return (dayOfYear / 30 + 1, dayOfYear % 30 + 1)
    }

    func dayRemoval(isSextil: Bool, day: inout Int, month: inout Int, year: inout Int) {
        day -= 1
        if day == 0 && month == 1 {
            day = isSextil ? 6 : 5
            year -= 1
            month = 13
        } else if day == 0 {
            day = 30
            month -= 1
        }
    }

    func dateToFrenchRepublican() -> DateComponents {
        let gregorian = Calendar.current.dateComponents([.year, .month, .day], from: date)
        var year = gregorian.year! - 1792
        var isSextil = year % 4 == 0
        year += (gregorian.month! > 9 || (gregorian.month == 9 && gregorian.day! >= (isSextil ? 23 : 22))) ? 1 : 0
        var (month, day) = simpleGregToRepDate()
        isSextil = year % 4 == 0
        if isSextil && (gregorian.month! < 3 || gregorian.month! > 9 || (gregorian.month == 9 && gregorian.day! >= 22)) {
            dayRemoval(isSextil: isSextil, day: &day, month: &month, year: &year)
        } else if isSextil && gregorian.month! >= 3 {
            day += 1
        }
        if gregorian.year! > 1800 || (gregorian.year! == 1800 && gregorian.month! >= 3) {
            dayRemoval(isSextil: isSextil, day: &day, month: &month, year: &year)
        }
        if gregorian.year! > 1900 || (gregorian.year! == 1900 && gregorian.month! >= 3) {
            dayRemoval(isSextil: isSextil, day: &day, month: &month, year: &year)
        }
        if gregorian.year! > 2100 || (gregorian.year! == 2100 && gregorian.month! >= 3) {
            dayRemoval(isSextil: isSextil, day: &day, month: &month, year: &year)
        }
        if day > 30 {
            day -= 30
            month += 1
        }
        if day < 1 {
            day += 30
            month -= 1
        }
        if month == 13 {
            if day > (isSextil ? 6 : 5) {
                day -= (isSextil ? 6 : 5)
                month = 1
                year += 1
            }
        }
        return DateComponents(year: year, month: month, day: day, hour: gregorian.hour, minute: gregorian.minute, second: gregorian.second, nanosecond: gregorian.nanosecond, weekday: day % 10, weekdayOrdinal: day / 10 + 1, quarter: month / 4 + 1, weekOfMonth: day / 10 + 1, weekOfYear: month * 3 + day / 10 + 1, yearForWeekOfYear: year)
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
