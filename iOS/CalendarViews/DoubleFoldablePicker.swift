//
//  DoubleFoldablePicker.swift
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

struct DoubleFoldablePicker<PickerView: View>: View {
    var label: Text
    var value1: Text
    var value2: Text
    var showSecond: Bool
    @Binding var showPicker1: Bool
    @Binding var showPicker2: Bool
    @ViewBuilder var pickerView: (Bool) -> PickerView
    
    var body: some View {
        VStack {
            HStack {
                label
                    .lineLimit(1)
                    .layoutPriority(1)
                Spacer()
                PickerButton(label: value1, showDetails: $showPicker1)
                    .lineLimit(1)
                    .layoutPriority(5)
                if showSecond {
                    PickerButton(label: value2, showDetails: $showPicker2)
                        .lineLimit(1)
                        .layoutPriority(5)
                }
            }.animation(nil, value: showPicker1 || showPicker2)
            ZStack {
                if showPicker1 || showPicker2 {
                    pickerView(showPicker2)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 0.01) // need > 0 for the view to exist but want 0
            .clipped()
            .animation(.default, value: showPicker1 || showPicker2)
        }.padding(.bottom, showPicker1 || showPicker2 ? 0 : -8)
    }
}
