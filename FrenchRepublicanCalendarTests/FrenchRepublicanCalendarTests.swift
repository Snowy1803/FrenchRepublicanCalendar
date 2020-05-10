//
//  FrenchRepublicanCalendarTests.swift
//  FrenchRepublicanCalendarTests
//
//  Created by Emil Pedersen on 19/04/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import XCTest

class FrenchRepublicanCalendarTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDateLinearity() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var date = Date(timeIntervalSince1970: -5594191200)
        var prevDay: Int?
        var prevYear: Int?
        for _ in 0..<1000000 {
            let frd = FrenchRepublicanDate(date: date)
            if prevDay != nil {
                if frd.dayInYear == 1 {
                    XCTAssert(prevDay == 365 || prevDay == 366, "Year ends after \(prevDay!) days")
                    XCTAssert(frd.components.year! - prevYear! == 1, "Year wasn't incremented")
                } else {
                    XCTAssert(frd.dayInYear - prevDay! == 1, "Invalid \(date) = \(frd.toLongString())")
                    XCTAssert(frd.components.year! == prevYear!, "Year changed without resetting day at \(frd.toLongString())")
                }
            }
            prevDay = frd.dayInYear
            prevYear = frd.components.year!
            
            let copy = FrenchRepublicanDate(dayInYear: prevDay!, year: prevYear!, hour: frd.components.hour, minute: frd.components.minute, second: frd.components.second, nanosecond: frd.components.nanosecond)
            
            XCTAssert(copy.date == date, "Reconversion fails for \(date) = \(frd.toLongString()) ≠ \(copy.date)")
            
            date.addTimeInterval(3600 * 24)
        }
    }
    
    func testCurrentDate() throws {
        print(FrenchRepublicanDate(date: Date()))
    }
    
    func testDayCount() throws {
        XCTAssert(FrenchRepublicanDate(date: Date()).DAYNAMES.count == 366)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
