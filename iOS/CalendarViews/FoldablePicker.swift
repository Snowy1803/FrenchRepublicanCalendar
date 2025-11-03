//
//  DecimalTimePicker.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 02/11/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct FoldablePicker<PickerView: View>: View {
    var label: Text
    var value: Text
    @Binding var showPicker: Bool
    @ViewBuilder var pickerView: () -> PickerView
    
    var body: some View {
        HStack {
            label.font(.headline)
                .lineLimit(1)
                .layoutPriority(1)
            Spacer()
            PickerButton(label: value, showDetails: $showPicker)
                .lineLimit(1)
                .layoutPriority(5)
        }.accessibilityElement(children: .combine)
        if showPicker {
            pickerView()
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

struct PickerButton: View {
    var label: Text
    @Binding var showDetails: Bool
    

    var body: some View {
        Button {
            withAnimation {
                showDetails.toggle()
            }
        } label: {
            label
                .foregroundStyle(showDetails ? Color.accentColor : .primary)
                .padding(10)
                .background(Capsule().fill(Color("PickerBackground")))
        }
        .buttonStyle(.plain)
        .accessibilityValue(label)
        .accessibilityHint(Text("Sélectionner pour développer"))
        .accessibilityAddTraits(showDetails ? .isSelected : [])
    }
}
