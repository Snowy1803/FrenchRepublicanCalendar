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
    var precision: DecimalTimePrecision
    @Binding var decimalTime: DecimalTime
    @Binding var showPicker: Bool
    
    var body: some View {
        HStack {
            text.font(.headline)
            Spacer()
            DecimalTimePickerButton(si: si, decimalTime: decimalTime, precision: precision, showDetails: $showPicker)
        }
        if showPicker {
            DecimalTimePickerView(si: si, precision: precision, selection: $decimalTime)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

struct DecimalTimePickerButton: View {
    var si: Bool
    var decimalTime: DecimalTime
    var precision: DecimalTimePrecision
    @Binding var showDetails: Bool
    
    var label: Text {
        if si {
            let date = Calendar.gregorian.startOfDay(for: Date())
                .addingTimeInterval(decimalTime.timeSinceMidnight)
            let format = Date.FormatStyle.dateTime
                .hour(.twoDigits(amPM: .abbreviated))
                .minute(.twoDigits)
            return Text(date, format: precision == .secondPrecision ? format.second(.twoDigits) : format)
        } else {
            return Text(decimalTime, format: .decimalTime.precision(precision))
        }
    }

    var body: some View {
        Group {
            Button {
                withAnimation {
                    showDetails.toggle()
                }
            } label: {
                label
            }
            .buttonStyle(.bordered)
        }
        .accessibilityLabel(Text(si ? "Temps SI" : "Temps décimal"))
        .accessibilityValue(label)
        .accessibilityHint(Text("Sélectionner pour développer"))
        .accessibilityAddTraits(showDetails ? .isSelected : [])
    }
}

struct DecimalTimePickerView: UIViewRepresentable {
    typealias UIViewType = UIPickerView
    var si: Bool
    var precision: DecimalTimePrecision
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
        if si {
            picker.selectRow(selection.hourSI, inComponent: 0, animated: false)
            picker.selectRow(selection.minuteSI, inComponent: 1, animated: false)
            if context.coordinator.numberOfComponents(in: picker) == 3 {
                picker.selectRow(selection.secondSI, inComponent: 2, animated: false)
            }
        } else {
            picker.selectRow(selection.hour, inComponent: 0, animated: false)
            picker.selectRow(selection.minute, inComponent: 1, animated: false)
            if context.coordinator.numberOfComponents(in: picker) == 3 {
                picker.selectRow(selection.second, inComponent: 2, animated: false)
            }
        }
        picker.reloadAllComponents()
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate {
        var si: Bool = false
        var precision: DecimalTimePrecision = .none
        var selection: Binding<DecimalTime> = .constant(DecimalTime(timeSinceMidnight: 0))
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            switch precision {
            case .none, .minutePrecision:
                2
            case .secondPrecision, .subsecondPrecision:
                3
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0: // hours
                si ? 24 : 10
            case 1, 2: // minutes, seconds
                si ? 60 : 100
            default:
                preconditionFailure()
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if !si && component == 0 {
                return String(row)
            }
            return String("0\(row)".suffix(2))
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch component {
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
            switch component {
            case 0: return "Heures"
            case 1: return "Minutes"
            case 2: return "Secondes"
            default: preconditionFailure()
            }
        }
    }
}
