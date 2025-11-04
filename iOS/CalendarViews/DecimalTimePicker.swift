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
    var si: Bool
    var text: Text
    var precision: DecimalTimeFormat
    @Binding var decimalTime: DecimalTime
    @Binding var showPicker: Bool
    
    var label: Text {
        if si {
            let date = Calendar.gregorian.startOfDay(for: Date())
                .addingTimeInterval(decimalTime.timeSinceMidnight)
            var format = Date.FormatStyle.dateTime
            switch precision.hour {
            case .long: format = format.hour(.twoDigits(amPM: .abbreviated))
            case .default: format = format.hour(.defaultDigits(amPM: .abbreviated))
            case .short: format = format.hour(.conversationalDefaultDigits(amPM: .abbreviated))
            case .none:
                break
            }
            switch precision.minute {
            case .long: format = format.minute(.twoDigits)
            case .default, .short: format = format.minute(.defaultDigits)
            case .none:
                break
            }
            switch precision.second {
            case .long: format = format.second(.twoDigits)
            case .default, .short: format = format.second(.defaultDigits)
            case .none:
                break
            }
            switch precision.subsecond {
            case .precision(let precision): format = format.secondFraction(.fractional(precision))
            case .none:
                break
            }
            return Text(date, format: format)
        } else {
            return Text(decimalTime, format: precision)
        }
    }
    
    var body: some View {
        FoldablePicker(label: text, value: label, showPicker: $showPicker) {
            DecimalTimePickerView(si: si, precision: precision, selection: $decimalTime)
        }
    }
}

struct DecimalTimePickerView: UIViewRepresentable {
    typealias UIViewType = UIPickerView
    var si: Bool
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
        context.coordinator.si = si
        context.coordinator.precision = precision
        context.coordinator.selection = $selection
        var component: Int = 0
        if precision.hour != .none {
            picker.selectRow(si ? selection.hourSI : selection.hour, inComponent: component, animated: false)
            component += 1
        }
        if precision.minute != .none {
            picker.selectRow(si ? selection.minuteSI : selection.minute, inComponent: component, animated: false)
            component += 1
        }
        if precision.second != .none {
            picker.selectRow(si ? selection.secondSI : selection.second, inComponent: component, animated: false)
            component += 1
        }
        picker.reloadAllComponents()
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate {
        var si: Bool = false
        var precision: DecimalTimeFormat = .decimalTime
        var selection: Binding<DecimalTime> = .constant(DecimalTime(timeSinceMidnight: 0))
        
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
