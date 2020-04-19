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

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var date = Date(timeIntervalSince1970: -5594191200)
        var prev: Int?
        for _ in 0..<100000 {
            let frd = FrenchRepublicanDate(date: date)
            if prev != nil {
                XCTAssert(frd.dayInYear - prev! == 1 || frd.dayInYear == 1, "Invalid \(date) = \(frd.toLongString())")
            }
            prev = frd.dayInYear
            
            date.addTimeInterval(3600 * 24)
        }
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
