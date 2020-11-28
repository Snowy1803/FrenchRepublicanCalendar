//
//  IntentHandler.swift
//  Siri
//
//  Created by Emil Pedersen on 28/11/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import Intents

class IntentHandler: INExtension, ConversionIntentHandling {
    
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
        let result = IntentRepublicanDate(identifier: rep.toShortenedString(), display: rep.toLongString())
        result.day = rep.components.day as NSNumber?
        result.month = rep.components.month as NSNumber?
        result.year = rep.components.year as NSNumber?
        result.monthName = rep.monthName
        result.dayName = rep.dayName
        result.weekDayName = rep.weekdayName
        response.date = result
        completion(response)
    }
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}
