//
//  DecimalTimeWidget.swift
//  FrenchRepublicanCalendar
//
//  Created by Emil Pedersen on 29/05/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct DecimalTimeWidget: View {
    var link: Bool
    
    var body: some View {
        HomeWidget {
            Image.decorative(systemName: "clock")
            Text("Temps décimal")
            Spacer()
        } content: {
            if link {
                NavigationLink(destination: DecimalTimeDetails()) {
                    HStack {
                        CurrentDecimalTime()
                        Spacer()
                        Image.decorative(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }.foregroundColor(.primary)
                }
            } else {
                HStack {
                    CurrentDecimalTime()
                    Spacer()
                }
            }
        }
    }
}

struct CurrentDecimalTime: View {
    let timer = Timer.publish(every: DecimalTime.decimalSecond / 10, on: .main, in: .common).autoconnect()
    
    @State private var time = DecimalTime()
    
    var body: some View {
        (
            Text(time.description)
                .font(.largeTitle.monospacedDigit())
            + Text(String(format: "%.1f", time.remainder).dropFirst())
                .font(.body.monospacedDigit())
        ).onReceive(timer) { _ in
            self.time = DecimalTime()
        }.accessibility(label: Text("\(time.hour) heures, \(time.minute) minutes, et \(time.second) secondes"))
    }
}

struct DecimalTimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        DecimalTimeWidget(link: false)
    }
}
