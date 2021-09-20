//
//  IntentHandler.swift
//  Siri
//
//  Created by Emil Pedersen on 28/11/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Intents
import FrenchRepublicanCalendarCore

class IntentHandler: INExtension, ConversionIntentHandling, CreateDateIntentHandling, RepublicanToGregorianIntentHandling {
    
    func handle(intent: ConversionIntent, completion: @escaping (ConversionIntentResponse) -> Void) {
        let date: Date
        if let gregorian = intent.gregorian {
            guard let greg = Calendar.gregorian.date(from: gregorian) else {
                completion(.init(code: .failure, userActivity: nil))
                return
            }
            date = greg
        } else {
            date = Date()
        }
        let rep = FrenchRepublicanDate(date: date)
        let response = ConversionIntentResponse(code: .success, userActivity: nil)
        response.date = createIntentRepublicanDate(from: rep)
        completion(response)
    }
    
    func handle(intent: CreateDateIntent, completion: @escaping (CreateDateIntentResponse) -> Void) {
        guard let objcday = intent.day,
              let objcmonth = intent.month,
              let objcyear = intent.year else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        let day = Int(truncating: objcday)
        let month = Int(truncating: objcmonth)
        let year = Int(truncating: objcyear)
        guard 0 < day && day <= 30,
              0 < month && month <= 13,
              0 < year,
              month != 13 || day <= (year % 4 == 0 ? 6 : 5) else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        let rep = FrenchRepublicanDate(dayInYear: (month - 1) * 30 + day, year: year)
        let response = CreateDateIntentResponse(code: .success, userActivity: nil)
        response.date = createIntentRepublicanDate(from: rep)
        completion(response)
    }
    
    func handle(intent: RepublicanToGregorianIntent, completion: @escaping (RepublicanToGregorianIntentResponse) -> Void) {
        guard let param = intent.date,
              let day = param.day,
              let month = param.month,
              let year = param.year else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        let rep = FrenchRepublicanDate(dayInYear: (Int(truncating: month) - 1) * 30 + Int(truncating: day), year: Int(truncating: year))
        let response = RepublicanToGregorianIntentResponse(code: .success, userActivity: nil)
        response.date = Calendar(identifier: .gregorian).dateComponents([.day, .month, .year], from: rep.date)
        completion(response)
    }
    
    func createIntentRepublicanDate(from rep: FrenchRepublicanDate) -> IntentRepublicanDate {
        let result = IntentRepublicanDate(identifier: rep.toShortenedString(), display: rep.toLongString())
        result.day = rep.components.day as NSNumber?
        result.month = rep.components.month as NSNumber?
        result.year = rep.components.year as NSNumber?
        result.monthName = rep.monthName
        result.dayName = rep.dayName
        result.weekDayName = rep.weekdayName
        return result
    }
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}
