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

struct FoldableDecimalTimePicker: View {
    var text: Text
    var precision: DecimalTimeFormat
    @Binding var decimalTime: DecimalTime
    @Binding var showPicker: Bool
    
    var label: Text {
        return Text(decimalTime, format: precision)
    }
    
    var body: some View {
        FoldablePicker(label: text, value: label, showPicker: $showPicker) {
            DecimalTimePickerView(precision: precision, selection: $decimalTime)
        }
    }
}

struct DecimalTimePickerView: UIViewRepresentable {
    typealias UIViewType = UIPickerView
    var precision: DecimalTimeFormat
    @Binding var selection: DecimalTime
    
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        // Without these, SwiftUI goes in an infinite loop on smaller devices
        picker.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        picker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.precision = precision
        context.coordinator.selection = $selection
        var component: Int = 0
        if precision.hour != .none {
            picker.selectRow(precision.useSI ? selection.hourSI : selection.hour, inComponent: component, animated: false)
            component += 1
        }
        if precision.minute != .none {
            picker.selectRow(precision.useSI ? selection.minuteSI : selection.minute, inComponent: component, animated: false)
            component += 1
        }
        if precision.second != .none {
            picker.selectRow(precision.useSI ? selection.secondSI : selection.second, inComponent: component, animated: false)
            component += 1
        }
        picker.reloadAllComponents()
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate {
        var precision: DecimalTimeFormat = .decimalTime
        var selection: Binding<DecimalTime> = .constant(DecimalTime(timeSinceMidnight: 0))
        
        var si: Bool {
            precision.useSI
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            var component: Int = 0
            if precision.hour != .none {
                component += 1
            }
            if precision.minute != .none {
                component += 1
            }
            if precision.second != .none {
                component += 1
            }
            return component
        }
        
        func resolve(component: Int) -> Int {
            var component = component
            if precision.hour == .none {
                // (minute, second) becomes (_, minute, second)
                component += 1
            }
            if precision.minute == .none && component >= 1 {
                // (hour, second) becomes (hour, _, seconds)
                component += 1
            }
            return component
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if component == 0 && precision.hour != .none {
                si ? 24 : 10 // hours
            } else {
                si ? 60 : 100 // minutes, seconds
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            // TODO: use formatter
            if !si && component == 0 && precision.hour != .none {
                return String(row)
            }
            return String("0\(row)".suffix(2))
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch resolve(component: component) {
            case 0:
                if si {
                    selection.wrappedValue.hourSI = row
                } else {
                    selection.wrappedValue.hour = row
                }
            case 1:
                if si {
                    selection.wrappedValue.minuteSI = row
                } else {
                    selection.wrappedValue.minute = row
                }
            case 2:
                if si {
                    selection.wrappedValue.secondSI = row
                } else {
                    selection.wrappedValue.second = row
                }
            default:
                preconditionFailure()
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, accessibilityLabelForComponent component: Int) -> String? {
            switch resolve(component: component) {
            case 0: return "Heures"
            case 1: return "Minutes"
            case 2: return "Secondes"
            default: preconditionFailure()
            }
        }
    }
}
