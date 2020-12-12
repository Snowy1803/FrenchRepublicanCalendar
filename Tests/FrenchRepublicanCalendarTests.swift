//
//  FrenchRepublicanCalendarTests.swift
//  FrenchRepublicanCalendarTests
//
//  Created by Emil Pedersen on 19/04/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import XCTest

class FrenchRepublicanCalendarTests: XCTestCase {

    func testDateLinearity() throws {
        var date = FrenchRepublicanDate.origin
        var prevDay: Int?
        var prevYear: Int?
        while date <= FrenchRepublicanDate.maxSafeDate {
            let frd = FrenchRepublicanDate(date: date)
            
            if let prevDay = prevDay,
               let prevYear = prevYear {
                if frd.dayInYear == 1 {
                    XCTAssert(prevDay == (prevYear % 4 == 0 ? 366 : 365), "Year ends after \(prevDay) days")
                    XCTAssert(frd.components.year! - prevYear == 1, "Year wasn't incremented")
                } else {
                    XCTAssert(frd.dayInYear - prevDay == 1, "Invalid \(date) = \(frd.toLongString())")
                    XCTAssert(frd.components.year! == prevYear, "Year changed without resetting day at \(frd.toLongString())")
                }
            }
            
            prevDay = frd.dayInYear
            prevYear = frd.components.year!
            
            let copy = FrenchRepublicanDate(dayInYear: prevDay!, year: prevYear!, hour: frd.components.hour, minute: frd.components.minute, second: frd.components.second, nanosecond: frd.components.nanosecond)
            
            XCTAssert(copy.date == date, "Reconversion fails for \(date) = \(frd.toLongString()) ≠ \(copy.date)")
            
            date = Calendar.gregorian.date(byAdding: .day, value: 1, to: date)!
        }
        print("Tested until (Gregorian):", date)
    }
    
    func testOriginDate() {
        let origin = FrenchRepublicanDate.origin
        let frd = FrenchRepublicanDate(date: origin)
        XCTAssert(frd.dayInYear == 1 && frd.components.year == 1, "Origin is wrong")
    }
    
    func testCurrentDate() throws {
        print(FrenchRepublicanDate(date: Date()))
    }
    
    func testDayCount() throws {
        XCTAssert(FrenchRepublicanDate.allDayNames.count == 366)
    }
    
    func testWiktionnaryEntries() throws {
        let session = URLSession(configuration: .default)
        let semaphore = DispatchSemaphore(value: 0)
        for i in FrenchRepublicanDate.allDayNames.indices {
            guard let url = FrenchRepublicanDate(dayInYear: i + 1, year: 1).descriptionURL else {
                XCTFail("invalid url for day #\(i): \(FrenchRepublicanDate.allDayNames[i])")
                return
            }
            let task = session.dataTask(with: url) { (data, response, error) in
                guard let response = response as? HTTPURLResponse else {
                    XCTFail("not http")
                    return
                }
                XCTAssertEqual(response.statusCode, 200, "Day \(i) not found")
                semaphore.signal()
            }
            task.resume()
            semaphore.wait()
        }
    }
}
