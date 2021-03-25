//
//  MyDateComponents.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import Foundation
import FrenchRepublicanCalendarCore

struct MyDateComponents {
    var day: Int
    var month: Int
    var year: Int
    
    var asdate: Date? {
        Calendar.gregorian.date(from: DateComponents(year: year, month: month, day: day))
    }
    
    var tofrd: FrenchRepublicanDate? {
        let date = self.asdate
        return date == nil ? nil : FrenchRepublicanDate(date: date!)
    }
    
    var asfrd: FrenchRepublicanDate {
        return FrenchRepublicanDate(dayInYear: (month - 1) * 30 + day, year: year)
    }
    
    var todate: Date {
        return self.asfrd.date
    }
    
    var string: String {
        "\(year)-\(month)-\(day)"
    }
}

extension Date {
    var toMyDateComponents: MyDateComponents {
        let comp = Calendar.gregorian.dateComponents([.day, .month, .year], from: self)
        return MyDateComponents(day: comp.day!, month: comp.month!, year: comp.year!)
    }
}

extension FrenchRepublicanDate {
    var toMyDateComponents: MyDateComponents {
        return MyDateComponents(day: components.day!, month: components.month!, year: components.year!)
    }
}


