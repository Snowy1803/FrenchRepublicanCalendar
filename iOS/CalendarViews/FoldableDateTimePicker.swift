//
//  FoldableDateTimePicker.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 14/01/2026.
//  Copyright © 2026 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct FoldableDateTimePicker: View {
    var label: Text
    var precision: DecimalTimeFormat
    @Binding var date: Date
    @Binding var showDatePicker: Bool
    @Binding var showTimePicker: Bool
    
    var dateValue: Text {
        Text(FrenchRepublicanDate(date: date),
             format: .republicanDate.day(.preferred).year(.long))
    }
    
    var timeValue: Text {
        return Text(DecimalTime(base: date), format: precision)
    }
    
    var body: some View {
        DoubleFoldablePicker(label: label, value1: dateValue, value2: timeValue, showSecond: precision.hour != .none, showPicker1: $showDatePicker, showPicker2: $showTimePicker) { showTime in
            if showTime {
                DecimalTimePickerView(precision: precision, selection: Binding {
                    DecimalTime(base: date)
                } set: { decimalTime in
                    let frc = FrenchRepublicanDate(date: date)
                    date = FrenchRepublicanDate(dayInYear: frc.dayInYear, year: frc.year, time: decimalTime.timeSinceMidnight).date
                })
            } else {
                RepublicanDatePicker(selection: Binding {
                    FrenchRepublicanDate(date: date)
                } set: { frc in
                    date = FrenchRepublicanDate(dayInYear: frc.dayInYear, year: frc.year, time: DecimalTime(base: date).timeSinceMidnight).date
                })
            }
        }
    }
}
