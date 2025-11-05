//
//  WheelRepublicanDatePicker.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 04/11/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct WheelRepublicanDatePicker: UIViewRepresentable {
    typealias UIViewType = UIPickerView
    var precision: FRCFormat
    @Binding var selection: FrenchRepublicanDate
    
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        // Without these, SwiftUI goes in an infinite loop on smaller devices
        picker.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        picker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        // On iPad (aka regular horizontal size class), which has a smaller date picker vertically, we want it to resize itself as well
        picker.setContentHuggingPriority(.defaultHigh, for: .vertical)
        picker.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.precision = precision
        context.coordinator.setSelectionBinding($selection)
        var component: Int = 0
        if precision.hasDay && precision.hasMonth {
            picker.selectRow(selection.components.day! - 1, inComponent: component, animated: false)
            component += 1
        }
        if precision.hasDay && !precision.hasMonth {
            picker.selectRow(selection.dayInYear - 1, inComponent: component, animated: false)
            component += 1
        }
        if precision.hasMonth {
            picker.selectRow(selection.components.month! - 1, inComponent: component, animated: false)
            component += 1
        }
        if precision.hasYear {
            picker.selectRow(selection.components.year! - 1, inComponent: component, animated: false)
            component += 1
        }
        picker.reloadAllComponents()
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate {
        var precision: FRCFormat
        @Binding var selection: FrenchRepublicanDate
        
        override init() {
            self.precision = .republicanDate
            self._selection = .constant(FrenchRepublicanDate(date: Date()))
        }
        
        func setSelectionBinding(_ binding: Binding<FrenchRepublicanDate>) {
            self._selection = binding
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            var component: Int = 0
            if precision.hasDay {
                component += 1
            }
            if precision.hasMonth {
                component += 1
            }
            if precision.hasYear {
                component += 1
            }
            return component
        }
        
        enum ResolvedComponent {
            case dayInMonth, dayInYear, month, year
        }
        
        func resolve(component: Int) -> ResolvedComponent {
            if precision.hasDay && precision.hasMonth && component == 0 {
                return .dayInMonth
            }
            if precision.hasDay && !precision.hasMonth && component == 0 {
                return .dayInYear
            }
            if !precision.hasDay && precision.hasMonth && component == 0 {
                return .month
            }
            if precision.hasDay && precision.hasMonth && component == 1 {
                return .month
            }
            return .year
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch resolve(component: component) {
            case .dayInMonth:
                if selection.isSansculottides {
                    if selection.isYearSextil {
                        6
                    } else {
                        5
                    }
                } else {
                    30
                }
            case .dayInYear:
                if selection.isYearSextil {
                    366
                } else {
                    365
                }
            case .month:
                13
            case .year:
                15300
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            switch resolve(component: component) {
            case .dayInMonth:
                return "\(row + 1)"
            case .dayInYear:
                return FRCFormat.republicanDate.day(.dayName).format(FrenchRepublicanDate(dayInYear: row + 1, year: selection.components.year!))
            case .month:
                return FRCFormat.republicanDate.day(.monthOnly).format(FrenchRepublicanDate(day: 1, month: row + 1, year: selection.components.year!))
            case .year:
                return FRCFormat.republicanDate.year(precision.year).format(FrenchRepublicanDate(dayInYear: 1, year: row + 1))
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch resolve(component: component) {
            case .dayInMonth:
                selection = FrenchRepublicanDate(day: row + 1, month: selection.components.month!, year: selection.components.year!)
            case .dayInYear:
                selection = FrenchRepublicanDate(dayInYear: row + 1, year: selection.components.year!)
            case .month:
                selection = FrenchRepublicanDate(day: selection.components.day!, month: row + 1, year: selection.components.year!)
            case .year:
                selection = FrenchRepublicanDate(dayInYear: selection.dayInYear, year: row + 1)
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, accessibilityLabelForComponent component: Int) -> String? {
            switch resolve(component: component) {
            case .dayInMonth:
                return "Jour du mois"
            case .dayInYear:
                return "Jour de l'année"
            case .month:
                return "Mois"
            case .year:
                return "Année"
            }
        }
    }
}

fileprivate extension FRCFormat {
    var hasDay: Bool {
        switch day {
        case .none, .monthOnly: return false
        case .dayName, .preferred: return true
        }
    }
    
    var hasMonth: Bool {
        switch day {
        case .none, .dayName: return false
        case .monthOnly, .preferred: return true
        }
    }
    
    var hasYear: Bool {
        year != .none
    }
}
