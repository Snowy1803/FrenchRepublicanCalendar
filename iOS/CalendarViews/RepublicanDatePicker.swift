//
//  CalendarMonthView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 03/11/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore

struct RepublicanDatePicker: View {
    @State private var month: FrenchRepublicanDate
    @Binding var selection: FrenchRepublicanDate
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var dragOffset: CGFloat = 0
    @State private var width: CGFloat = 0
    @State private var showMonthWheel: Bool = false

    init(selection: Binding<FrenchRepublicanDate>) {
        self.month = FrenchRepublicanDate(day: 1, month: selection.wrappedValue.components.month!, year: selection.wrappedValue.components.year!)
        self._selection = selection
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showMonthWheel.toggle()
                    }
                } label: {
                    Text(month, format: .republicanDate.day(.monthOnly).year(.long))
                        .animation(nil, value: month)
                        .foregroundStyle(showMonthWheel ? Color.accentColor : Color.primary)
                    Image(systemName: "chevron.forward")
                        .imageScale(.small)
                        .foregroundStyle(.tint)
                        .rotationEffect(showMonthWheel ? .degrees(90) : .degrees(0))
                }
                .font(.headline)
                Spacer()
                Button {
                    previousMonth()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.foreground)
                        .font(.title3.weight(.semibold))
                }.padding(.trailing)
                Button {
                    nextMonth()
                } label: {
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.foreground)
                        .font(.title3.weight(.semibold))
                }
            }
            .padding()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Mois"))
            .accessibilityValue(Text(month, format: .republicanDate.day(.monthOnly).year(.long)))
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    nextMonth()
                case .decrement:
                    previousMonth()
                @unknown default:
                    ()
                }
            }
            ZStack {
                GeometryReader { geo in
                    Color.clear
                        .onAppear { width = geo.size.width }
                        .onChange(of: geo.size.width) { width = $0 }
                }
                CalendarMonthView(month: prevMonth, selection: $selection, halfWeek: sizeClass == .compact, constantHeight: true)
                    .id(prevMonth)
                    .offset(x: -width)
                    .accessibilityHidden(true)
                CalendarMonthView(month: month, selection: $selection, halfWeek: sizeClass == .compact, constantHeight: true)
                    .id(month)
                    .accessibilityHidden(showMonthWheel)
                CalendarMonthView(month: followingMonth, selection: $selection, halfWeek: sizeClass == .compact, constantHeight: true)
                    .id(followingMonth)
                    .offset(x: width)
                    .accessibilityHidden(true)
            }
            .offset(x: dragOffset)
            .overlay { // keep size from month view
                if showMonthWheel {
                    ZStack {
                        Rectangle()
                            .fill(.background)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        WheelRepublicanDatePicker(precision: .republicanDate.day(.monthOnly).year(), selection: $month)
                    }.transition(.opacity)
                }
            }
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 10).onChanged { value in
                    dragOffset = value.translation.width
                }.onEnded { value in
                    let threshold = width / 2
                    let forward: Bool?
                    if value.predictedEndTranslation.width < -threshold {
                        forward = true
                    } else if value.predictedEndTranslation.width > threshold {
                        forward = false
                    } else {
                        forward = nil
                    }
                    swipeMonth(
                        animation: .interpolatingSpring(
                            stiffness: 170,
                            damping: 20,
                            initialVelocity: value.velocity.width / width
                        ),
                        forward: forward
                    )
                },
                isEnabled: !showMonthWheel
            )
        }
    }
    
    var prevMonth: FrenchRepublicanDate {
        if month.components.month! == 1 {
            FrenchRepublicanDate(
                day: 1,
                month: 13,
                year: self.month.components.year! - 1
            )
        } else {
            FrenchRepublicanDate(
                day: 1,
                month: self.month.components.month! - 1,
                year: self.month.components.year!
            )
        }
    }
    
    var followingMonth: FrenchRepublicanDate {
        if month.isSansculottides {
            FrenchRepublicanDate(
                day: 1,
                month: 1,
                year: self.month.components.year! + 1
            )
        } else {
            FrenchRepublicanDate(
                day: 1,
                month: self.month.components.month! + 1,
                year: self.month.components.year!
            )
        }
    }
    
    func swipeMonth(animation: Animation, forward: Bool?) {
        func animated() {
            switch forward {
            case true: dragOffset = -width
            case false: dragOffset = width
            case nil: dragOffset = 0
            }
        }
        func end() {
            if let forward {
                dragOffset = 0
                if forward {
                    month = followingMonth
                } else {
                    month = prevMonth
                }
            }
        }
        if #available(iOS 17.0, *) {
            withAnimation(animation) {
                animated()
            } completion: {
                end()
            }
        } else {
            withAnimation(animation) {
                animated()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                end()
            }
        }
    }
    
    func previousMonth() {
        swipeMonth(animation: .default, forward: false)
    }
    
    func nextMonth() {
        swipeMonth(animation: .default, forward: true)
    }
}

struct FoldableDatePicker: View {
    var si: Bool
    var label: Text
    @Binding var date: Date
    @Binding var showPicker: Bool
    
    var value: Text {
        if si {
            Text(date,
                 format: .dateTime.day().month(.wide).year())
        } else {
            Text(FrenchRepublicanDate(date: date),
                 format: .republicanDate.day(.preferred).year(.long))
        }
    }
    
    var body: some View {
        FoldablePicker(label: label, value: value, showPicker: $showPicker) {
            if si {
                DatePicker(selection: $date, in: FrenchRepublicanDate.origin..., displayedComponents: .date) {
                    label
                }.frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.locale, Locale(identifier: "fr"))
                .datePickerStyle(.graphical)
                .labelsHidden()
            } else {
                RepublicanDatePicker(selection: Binding {
                    FrenchRepublicanDate(date: date)
                } set: {
                    date = $0.date
                })
            }
        }
    }
}
