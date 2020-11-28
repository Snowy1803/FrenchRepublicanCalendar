//
//  IntentHandler.swift
//  Siri
//
//  Created by Emil Pedersen on 28/11/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import Intents

class IntentHandler: INExtension, ConversionIntentHandling, CreateDateIntentHandling, RepublicanToGregorianIntentHandling {
    
    func handle(intent: ConversionIntent, completion: @escaping (ConversionIntentResponse) -> Void) {
        let date: Date
        if let gregorian = intent.gregorian {
            guard let greg = Calendar.current.date(from: gregorian) else {
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
        guard let day = intent.day,
              let month = intent.month,
              let year = intent.year,
              month != 13 || Int(truncating: day) <= (Int(truncating: year) % 4 == 0 ? 6 : 5) else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        let rep = FrenchRepublicanDate(dayInYear: (Int(truncating: month) - 1) * 30 + Int(truncating: day), year: Int(truncating: year))
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
        response.date = Calendar.current.dateComponents([.day, .month, .year], from: rep.date)
        completion(response)
    }
    
    func createIntentRepublicanDate(from rep: FrenchRepublicanDate) -> IntentRepublicanDate{
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
