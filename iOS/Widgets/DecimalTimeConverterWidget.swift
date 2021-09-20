//
//  DecimalTimeConverterWidget.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 30/05/2021.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct DecimalTimeConverterWidget: View {
    @EnvironmentObject var midnight: Midnight
    @State private var time = DecimalTime()
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "arrow.right.arrow.left")
            Text("Convertir")
            Spacer()
        } content: {
            HStack {
                Text("Temps SI : ")
                Spacer()
                SITimePicker(time: $time)
            }
            Divider()
            HStack {
                Text("Temps décimal : ")
                Spacer()
                DecimalTimePicker(time: $time)
            }
        }
    }
}
