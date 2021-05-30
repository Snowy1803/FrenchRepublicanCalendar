//
//  DecimalTimeConverterWidget.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 30/05/2021.
//  Copyright © 2020 Snowy_1803. All rights reserved.
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
